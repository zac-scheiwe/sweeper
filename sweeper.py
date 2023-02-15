import time, sys, os, smtplib, ssl
from math import isnan
from ib_insync import *
# util.startLoop()  # uncomment this line when in a notebook

env_params = dict(os.environ)

DEPOSIT_CURRENCY = env_params['DEPOSIT_CURRENCY']
TRADE_CURRENCY = env_params['TRADE_CURRENCY']
STOCK_TICKER = env_params['STOCK_TICKER']

DEPOSIT_BALANCE_THRESHOLD = float(env_params['DEPOSIT_BALANCE_THRESHOLD'])
TRADE_BALANCE_THRESHOLD = float(env_params['TRADE_BALANCE_THRESHOLD'])
BPS_SAFETY = float(env_params['BPS_SAFETY'])

ib = IB()

def send_email(message):
    sender_gmail = env_params['SENDER_GMAIL_ADDRESS']
    sender_gmail_app_password = env_params['SENDER_GMAIL_APP_PASSWORD']
    receiver_email = env_params['RECEIVER_EMAIL_ADDRESS']

    context = ssl.create_default_context()
    with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
        server.login(sender_gmail, sender_gmail_app_password)
        server.sendmail(sender_gmail, receiver_email, message)

def connect():
    connection_wait_time = 60
    ib.sleep(connection_wait_time)

    try:
        ib.connect('127.0.0.1', 4000, clientId=1)  # IB Gateway
        # ib.connect('127.0.0.1', 7497, clientId=1)  # TWS
    except ConnectionRefusedError:
        message = f"""Subject: IB Gateway connection failed

        Time: {time.ctime()}
        Could not connect after waiting {connection_wait_time} seconds after container start.
        """
        send_email(message)
        sys.exit()

def get_cash_balance(currency):
    cash_balances = {x.currency: float(x.value) for x in ib.accountSummary() if x.tag == 'CashBalance'}
    if currency in cash_balances:
        return cash_balances[currency]
    else:
        return 0.0

def convert_deposit_currency_to_trade_currency(deposit_amount):
    fx_contract = Forex(DEPOSIT_CURRENCY+TRADE_CURRENCY)
    ib.qualifyContracts(fx_contract)
    fx_order = MarketOrder('SELL', deposit_amount)
    fx_trade = ib.placeOrder(fx_contract, fx_order)
    return fx_trade

def get_updated_balance(initial_trade_balance):
    trade_balance = get_cash_balance(TRADE_CURRENCY)
    balance_request_attempts = 1
    while trade_balance == initial_trade_balance:
        ib.sleep(1)
        trade_balance = get_cash_balance(TRADE_CURRENCY)
        balance_request_attempts += 1
        if balance_request_attempts >= 10:
            return None
    return get_cash_balance(TRADE_CURRENCY)

def get_stock_contract(ticker, exchange, currency):
    contract = Stock(ticker, exchange, currency)
    ib.qualifyContracts(contract)
    return contract

def get_market_price(contract):
    ib.reqMarketDataType(4)  # Request frozen delayed market data
    market_data = ib.reqMktData(contract)
    ib.sleep(5)
    if isnan(market_data.marketPrice()):
        return None
    return market_data.marketPrice()

def get_limit_price_and_qty(cash_value_target, market_price, bps_safety):  # for buy order
    min_limit_price = market_price * (1 + bps_safety/1e4)
    limit_qty = int(cash_value_target / min_limit_price)
    limit_price = int(cash_value_target * 100 / limit_qty) / 100   # Rounding down to 2dp
    return limit_price, limit_qty

def submit_auction_buy_order(contract, cash_value_target):
    market_price = get_market_price(contract)
    if market_price is None:
        return None
    limit_price, limit_qty = get_limit_price_and_qty(cash_value_target, market_price, BPS_SAFETY)
    order = Order(action='BUY', orderType='LOC', totalQuantity=limit_qty, 
                  lmtPrice=limit_price, transmit=True, usePriceMgmtAlgo=True)
    trade = ib.placeOrder(contract, order)
    return trade

# Connect to IB Gateway API
connect()

initial_deposit_balance = get_cash_balance(DEPOSIT_CURRENCY)
initial_trade_balance = get_cash_balance(TRADE_CURRENCY)

# If sufficient {DEPOSIT_CURRENCY} funds, convert all {DEPOSIT_CURRENCY} to {TRADE_CURRENCY}.
if initial_deposit_balance > DEPOSIT_BALANCE_THRESHOLD:
    fx_trade = convert_deposit_currency_to_trade_currency(int(initial_deposit_balance))
    trade_balance = get_updated_balance(initial_trade_balance)
    if trade_balance == initial_trade_balance:
        # Send email FX trade failed
        message = f"""Subject: FX trade failed

        Time: {time.ctime()}
        {DEPOSIT_CURRENCY} balance before: {initial_deposit_balance} {DEPOSIT_CURRENCY} 
        {DEPOSIT_CURRENCY} balance after: {get_cash_balance(DEPOSIT_CURRENCY)} {DEPOSIT_CURRENCY} 
        {TRADE_CURRENCY} balance before: {initial_trade_balance} {TRADE_CURRENCY} 
        {TRADE_CURRENCY} balance after: {get_cash_balance(TRADE_CURRENCY)} {TRADE_CURRENCY} 
        """
        send_email(message)
else:
    trade_balance = initial_trade_balance

# If sufficient {TRADE_CURRENCY} funds, buy {STOCK_TICKER} in closing auction.
if trade_balance > TRADE_BALANCE_THRESHOLD:
    stock_contract = get_stock_contract(STOCK_TICKER, 'SMART', TRADE_CURRENCY)
    stock_trade = submit_auction_buy_order(stock_contract, trade_balance)
    ib.sleep(5)
    if stock_trade is None:
        message = f"""Subject: Stock trade failed

        Time: {time.ctime()}
        {STOCK_TICKER} price could not be fetched.
        {DEPOSIT_CURRENCY} balance before: {initial_deposit_balance} {DEPOSIT_CURRENCY} 
        {DEPOSIT_CURRENCY} balance after: {get_cash_balance(DEPOSIT_CURRENCY)} {DEPOSIT_CURRENCY} 
        {TRADE_CURRENCY} balance before: {initial_trade_balance} {TRADE_CURRENCY} 
        {TRADE_CURRENCY} balance after: {get_cash_balance(TRADE_CURRENCY)} {TRADE_CURRENCY} 
        """
        send_email(message)

ib.disconnect()
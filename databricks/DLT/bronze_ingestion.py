import dlt
from pyspark.sql.functions import *
import requests
import time

SYMBOLS = ["AAPL", "MSFT", "GOOGL", "AMZN"]


@dlt.table(
    name = "bronze_quotes",
    comment = "Raw daily quote data from Alpha Vantage API"
)
def bronze_quotes():
    API_KEY = dbutils.secrets.get(scope="alpha-vantage", key="api-key")
    all_quotes = []
    for symbol in SYMBOLS:
        url = f"https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol={symbol}&apikey={API_KEY}"
        response = requests.get(url)
        data = response.json()
        quote = data["Global Quote"]

        row = {
            "symbol": quote["01. symbol"],
            "open": quote["02. open"],
            "high": quote["03. high"],
            "low": quote["04. low"],
            "price": quote["05. price"],
            "volume": quote["06. volume"],
            "latest_trading_day": quote["07. latest trading day"],
            "previous_close": quote["08. previous close"],
            "change": quote["09. change"],
            "change_percent": quote["10. change percent"]
        }
        all_quotes.append(row)
        time.sleep(15) 
    df = spark.createDataFrame(all_quotes)
    return df


@dlt.table(
    name = "bronze_price_history",
    comment = "Raw daily price history (last ~100 days) from Alpha Vantage API"
)
def bronze_price_history():
    API_KEY = dbutils.secrets.get(scope="alpha-vantage", key="api-key")
    all_rows = []
    for symbol in SYMBOLS:
        url = f"https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol={symbol}&apikey={API_KEY}"
        response = requests.get(url)
        data = response.json()
        time_series = data["Time Series (Daily)"]
        for date, values in time_series.items():
            row = {
                "symbol": symbol,
                "date": date,
                "open": values["1. open"],
                "high": values["2. high"],
                "low": values["3. low"],
                "close": values["4. close"],
                "volume": values["5. volume"]
            }
            all_rows.append(row)
        time.sleep(15) 
    df = spark.createDataFrame(all_rows)
    return df


@dlt.table(
    name = "bronze_company_info",
    comment = "Raw company overview data from Alpha Vantage API"
)
def bronze_company_info():
    API_KEY = dbutils.secrets.get(scope="alpha-vantage", key="api-key")
    all_companies = []
    for symbol in SYMBOLS:
        url = f"https://www.alphavantage.co/query?function=OVERVIEW&symbol={symbol}&apikey={API_KEY}"
        response = requests.get(url)
        data = response.json()
        all_companies.append(data)
        time.sleep(15) 
    df = spark.createDataFrame(all_companies)
    return df
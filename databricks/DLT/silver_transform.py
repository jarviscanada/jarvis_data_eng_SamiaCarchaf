import dlt
from pyspark.sql.functions import *

@dlt.table(
    name = "silver_quotes",
    comment = "Cleaned daily quote data with proper types"
)
def silver_quotes():
    df = dlt.read("bronze_quotes")
    
    df_clean = df.select(
        col("symbol"),
        col("open").cast("double"),
        col("high").cast("double"),
        col("low").cast("double"),
        col("price").cast("double"),
        col("volume").cast("long"),
        to_date(col("latest_trading_day")).alias("latest_trading_day"),
        col("previous_close").cast("double"),
        col("change").cast("double"),
        regexp_replace(col("change_percent"), "%", "").cast("double").alias("change_percent")
    )
    
    return df_clean

@dlt.table(
    name = "silver_price_history",
    comment = "Cleaned daily price history with proper types"
)
def silver_price_history():
    df = dlt.read("bronze_price_history")
    
    df_clean = df.select(
        col("symbol"),
        to_date(col("date")).alias("date"),
        col("open").cast("double"),
        col("high").cast("double"),
        col("low").cast("double"),
        col("close").cast("double"),
        col("volume").cast("long")
    )
    
    return df_clean

@dlt.view(
    name = "bronze_company_info_clean"
)
def bronze_company_info_clean():
    df = spark.readStream.option("skipChangeCommits", "true").table("LIVE.bronze_company_info")
    
    df_clean = df.select(
        col("Symbol").alias("symbol"),
        col("Name").alias("name"),
        col("Sector").alias("sector"),
        col("Industry").alias("industry"),
        col("Description").alias("description"),
        col("MarketCapitalization").cast("double").alias("market_cap"),
        col("PERatio").cast("double").alias("pe_ratio"),
        current_timestamp().alias("processing_timestamp")
    )
    
    return df_clean

dlt.create_streaming_table("silver_company_info")

dlt.apply_changes(
    target = "silver_company_info",
    source = "bronze_company_info_clean",
    keys = ["symbol"],
    sequence_by = col("processing_timestamp"),
    stored_as_scd_type = 1
)

import dlt
from pyspark.sql.functions import *
from pyspark.sql.window import Window

@dlt.table(
    name = "gold_price_trends",
    comment = "Price trend analysis: change over 7, 30, 90 days"
)
def gold_price_trends():
    df = dlt.read("silver_price_history")
    
    window_spec = Window.partitionBy("symbol").orderBy("date")
    
    df_trends = df.select(
        col("symbol"),
        col("date"),
        col("close"),
        lag("close", 7).over(window_spec).alias("close_7d_ago"),
        lag("close", 30).over(window_spec).alias("close_30d_ago"),
        lag("close", 90).over(window_spec).alias("close_90d_ago")
    )
    
    df_final = df_trends.select(
        col("symbol"),
        col("date"),
        col("close"),
        (col("close") - col("close_7d_ago")).alias("price_change_7d"),
        (col("close") - col("close_30d_ago")).alias("price_change_30d"),
        (col("close") - col("close_90d_ago")).alias("price_change_90d"),
        round(((col("close") - col("close_7d_ago")) / col("close_7d_ago")) * 100, 2).alias("price_change_pct_7d"),
        round(((col("close") - col("close_30d_ago")) / col("close_30d_ago")) * 100, 2).alias("price_change_pct_30d"),
        round(((col("close") - col("close_90d_ago")) / col("close_90d_ago")) * 100, 2).alias("price_change_pct_90d")
    )
    
    return df_final

@dlt.table(
    name = "gold_volume_trends",
    comment = "Volume trend analysis: change over 7, 30, 90 days"
)
def gold_volume_trends():
    df = dlt.read("silver_price_history")
    
    window_spec = Window.partitionBy("symbol").orderBy("date")
    
    df_trends = df.select(
        col("symbol"),
        col("date"),
        col("volume"),
        lag("volume", 7).over(window_spec).alias("volume_7d_ago"),
        lag("volume", 30).over(window_spec).alias("volume_30d_ago"),
        lag("volume", 90).over(window_spec).alias("volume_90d_ago")
    )
    
    df_final = df_trends.select(
        col("symbol"),
        col("date"),
        col("volume"),
        (col("volume") - col("volume_7d_ago")).alias("volume_change_7d"),
        (col("volume") - col("volume_30d_ago")).alias("volume_change_30d"),
        (col("volume") - col("volume_90d_ago")).alias("volume_change_90d"),
        round(((col("volume") - col("volume_7d_ago")) / col("volume_7d_ago")) * 100, 2).alias("volume_change_pct_7d"),
        round(((col("volume") - col("volume_30d_ago")) / col("volume_30d_ago")) * 100, 2).alias("volume_change_pct_30d"),
        round(((col("volume") - col("volume_90d_ago")) / col("volume_90d_ago")) * 100, 2).alias("volume_change_pct_90d")
    )
    
    return df_final
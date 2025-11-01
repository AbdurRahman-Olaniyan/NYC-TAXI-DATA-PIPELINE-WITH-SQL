import pandas as pd
from pathlib import Path

# Define the folder containing Parquet files
data_dir = Path('C:/nyc_tlc_2024/nyc_tlc_2024_parquet')

# Define an output folder for the CSVs
output_dir = Path('C:/nyc_tlc_2024/nyc_tlc_2024_csv')
output_dir.mkdir(parents=True, exist_ok=True)

# Find all Parquet files in the directory
parquet_files = list(data_dir.glob('*.parquet'))

if not parquet_files:
    print(f"No parquet files found in the directory: {data_dir}")
else:
    for parquet_file in parquet_files:
        # Read the Parquet file
        df = pd.read_parquet(parquet_file)

        # Generate the corresponding CSV filename
        csv_file = output_dir / f"{parquet_file.stem}.csv"

        # Save to CSV
        df.to_csv(csv_file, index=False)

        print(f"Converted '{parquet_file.name}' → '{csv_file.name}'")

    print(f"\n✅ Successfully converted {len(parquet_files)} Parquet files to CSV format in {output_dir}")

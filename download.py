#!/usr/bin/env python3

import csv
import requests
import click

@click.command(context_settings=dict(help_option_names=['-h', '--help']))
@click.option('-i', '--input-file', type=click.Path(exists=True), required=True, help='Input CSV file with URLs')
def download(input_file):
    """
    Parse a CSV file of URLs and display HTTP status codes and request times.

    This script reads an input CSV file where each line contains a name and a URL separated by a pipe ('|'). 
    It then makes HTTP GET requests to each URL and prints the name, HTTP status code, and the time taken for the request.

    Args:
        input_file (str): Path to the input CSV file containing names and URLs.
    """
    
    with open(input_file, 'r') as file:
        reader = csv.reader(file, delimiter='|')
        for row in reader:
            name, url = row # Unpack the row into name and URL
            try:
                response = requests.get(url,timeout=3)
                status_code = response.status_code
                elapsed_time = response.elapsed.total_seconds()
                click.echo(f'"{name}", HTTP {status_code}, time {elapsed_time:.2f} seconds')
            except requests.exceptions.RequestException:
                click.echo(f'Skipping {url}')

if __name__ == '__main__':
    download()
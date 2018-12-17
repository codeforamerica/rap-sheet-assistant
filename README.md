# README

## Setup
 - `brew bundle` to install system dependencies
 - Install ruby version specified in `.ruby-version`.
   
   Note: We recommend using `chruby` to manage Ruby versions locally.
 - `bundle` to install dependencies
 - `rake db:setup` to install database in development and test.
 - `rake` to run unit test suite
 - `rails s` to run the server locally

 - Install ElasticBeanstalk CLI
   `sudo pip install awsebcli`

 - [Install PDFTK from here](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk_server-2.02-mac_osx-10.11-setup.pkg)

## Integration tests
This repo also includes an integration test suite which has the ability to take in a set of RAP sheet images and expectations and ensure that the parsed RAP sheets agree with the expectations.
The test suite will compute an accuracy percentage for how well the output matched the expectations.

You can run the integration tests with `rake ocr`.
 
The test suite expects a local folder or Amazon S3 bucket containing subfolders for each RAP sheet to be tested.  
In each subfolder, it expects to find an image file for each page of the RAP sheet named `page_#.jpg`, where `#` is replaced by the page number.
Additionally, the subfolder should contain a JSON file named `expected_values.json`.  

For example:
```
test_raps/
  rap_sheet_001/
    expected_values.json
    page_1.jpg
    page_2.jpg
  rap_sheet_002/
    expected_values.json
    page_1.jpg
    page_2.jpg
    page_3.jpg
```

The structure of the `expected_values.json` file is as follows:
```json
{
  "custody_events": [
    {
      "date": "4/12/2013"
    }
  ],
  "arrests": [
    {
      "date": "10/15/2011"
    },
    {
      "date": "02/05/2015"
    },
  ],
  "convictions": [
    {
      "date": "8/25/2013",
      "case_number": "555666777",
      "courthouse": "CASC SAN FRANCISCO CO",
      "counts": [
        {
          "code_section": "PC 602(G)"
        },
        {
          "code_section": "PC 602(E)",
          "severity": "M",
          "sentence": "6m probation, fine"
        }
      ]
    }
  ]
}
``` 
**NOTE:** only court events that result in a conviction are included, and only convicted charges on the event are included.

In order to use a local folder, set the environment variable `LOCAL_RAP_SHEETS_DIR`

When running the tests verbose output is hidden by default. If you are running OCR tests on a system that is CJI/PII safe you can set the `RSPEC_SHOW_OCR_OUTPUT` environment variable to see summary output

In order to use AWS S3, ensure the following environment variables are set:
```
RAP_SHEETS_BUCKET
AWS_ACCESS_KEY_ID
AWS_SECRET_KEY
```
If you would like to only run the tests on one specific RAP sheet, set the environment variable `TEST_DIR` to the subfolder for that RAP sheet.

**Caching:**
Because the OCR step is the slowest and most expensive step in the process, the tests will automatically cache the OCR results as a text file `page_#.txt` for each page.
If a text file exists, the OCR will not be run, the text file will be used instead. To clear the cache, simply delete the `.txt` files from the subfolder.

**Creating test images for the test suite:**
If you have a PDF of a RAP sheet and you would like to create jpgs of each page for the test suite to consume, you can run `rake upload_test_images["my_test_rap_sheet"]`, where `my_test_rap_sheet.pdf` is the name of the file you wish to convert.
This will create a file for each page and upload it to a folder in your S3 bucket with the name provided.

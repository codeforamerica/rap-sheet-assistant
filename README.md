# README
**🚫 This repository has been archived**

**Please see below for more background on the project, and please reach out to clearmyrecord@codeforamerica.org for questions.**

## Prerequisites
 - [chromedriver](http://chromedriver.chromium.org/) installed. `brew install chromedriver` with homebrew.

 - PostgreSQL with [pgcrypto](https://www.postgresql.org/docs/current/pgcrypto.html) running
 
   Note: Change the setttings in `config/database.yml` if the database is not at `localhost:5432`.

 - Access to a [Google Cloud](https://cloud.google.com) project with the [Cloud Vision API](https://cloud.google.com/vision/docs/) enabled
 
   The enviroment variable `GOOGLE_CLOUD_KEYFILE` should point at a file containing your [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys#creating_service_account_keys).

## Setup
 - `brew bundle` to install system dependencies
 - Install ruby version specified in `.ruby-version`
   
   Note: We recommend using `chruby` to manage Ruby versions locally.
 - `bundle` to install dependencies
 - `rake db:setup` to install database in development and test
 - Install ElasticBeanstalk CLI
   `sudo pip install awsebcli`

 - [Install PDFTK from here](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk_server-2.02-mac_osx-10.11-setup.pkg)
 - `rake` to run unit test suite
 - `rails s` to run the server locally
## Running in CI
This repo has a CircleCI config and internal tests are run (privately) in CircleCI. CfA members should ask the Clear My Record team for access. 
There is a `Dockerfile` in this repo that we use due to version issues with the `circleci/ruby:node-browsers`. In particular this Dockerfile installs
the latest version of Chrome and ChromeDriver as well as PDFTK. We do not rebuild the Docker image every time to avoid bumping versions unnecessarily.
The image is pushed to the `codeforamerica/rap-sheet-assistant-ci` docker hub repo.

## Integration tests
This repo also includes an integration test suite which has the ability to take in a set of RAP sheet images and expectations and ensure that the parsed RAP sheets agree with the expectations.
The test suite will compute an accuracy percentage for how well the output matched the expectations.

You can run the integration tests with `rake ocr`. Set the `RSPEC_SHOW_OCR_OUTPUT` environment variable for detailed test output.
 
The test suite expects either a local folder or Amazon S3 bucket containing RAP sheets.

In order to use a local folder, set the environment variable `LOCAL_RAP_SHEETS_DIR` to point to the desired folder. If this environment variable is set, it will override the AWS environment variables.

In order to use AWS S3, ensure the following environment variables are set:
```
RAP_SHEETS_BUCKET
AWS_ACCESS_KEY_ID
AWS_SECRET_KEY
# Bucket containing test raps in the following folder format
RAP_SHEETS_BUCKET
```  

The RAP sheets folder should contain a subfolder for each RAP sheet to be tested. In each subfolder, it expects to find an image file for each page of the RAP sheet named `page_#.jpg`, where `#` is replaced by the page number.
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
    }
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

When running the tests verbose output is hidden by default. If you are running OCR tests on a system that is CJI/PII safe you can set the `RSPEC_SHOW_OCR_OUTPUT` environment variable to see summary output

If you would like to only run the tests on one specific RAP sheet, set the environment variable `TEST_DIR` to the subfolder for that RAP sheet.

**Caching:**
Because the OCR step is the slowest and most expensive step in the process, the tests will automatically cache the OCR results as a text file `page_#.txt` for each page.
If a text file exists, the OCR will not be run, the text file will be used instead. To clear the cache, simply delete the `.txt` files from the subfolder.

**Creating test images for the test suite:**
If you have a PDF of a RAP sheet and you would like to create jpgs of each page for the test suite to consume, you can run `rake upload_test_images["my_test_rap_sheet"]`, where `my_test_rap_sheet.pdf` is the name of the file you wish to convert.
This will create a file for each page and upload it to a folder in your S3 bucket with the name provided.

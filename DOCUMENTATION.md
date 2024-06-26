# Geocint Open Source documentation

* Geocint folder structure
* Geocint open-source installation and first run guide
    * Versions
    * Installation
    * First run
    * How to create your custom part of pipeline
* How geocint pipeline works
    * How start_geocint.sh works
    * How to write targets
    * How make.lock file work
    * User schemas in the database
    * How to analyse the build time for targets
* Make-profiler
* Best practices of using

## Geocint folder structure

Geocint consists of 3 different parts:
- [geocint-runner](https://github.com/konturio/geocint-runner) - a core part of the pipeline, includes utilities and initial Makefile
- [geocint-mapaction-osm](https://github.com/mapaction/geocint-mapaction) - a chain of targets for downloading, updating data/out/country_extractions/ on the geocint after build
- [geocint-mapaction](https://github.com/mapaction/geocint-mapaction/tree/main) - an opensource geodata ETL/CI/CD pipeline 

During the installation of the geocint pipeline the next folder will be created in your working directory:

- [public_html] - any public html that you want to share (use standard nginx logs to get information)

In general case geocint folder includes the next files and folders :
- [scripts/Makefile](scripts/Makefile) - makefile for geocint installation
- [start_geocint.sh](start_geocint.sh) - script, that runs the pipeline: checking required packages, cleaning targets and
  posting info messages
- [runner-install.sh](runner-install.sh) - script, that runs installation of required packages of the geocint-runner part
- [config.inc.sh.sample](config.inc.sh.sample) - a sample config file
- [runner_make](runner_make) - map dependencies between data generation stages
- [osm_make](runner_make) - makefile with a set of targets
- [your_make.sample](your_make.sample) - sample makefile that shows how to integrate geocint-runner, 
geocint-openstreetmap and your own chains of targets
- [scripts/](scripts) - scripts that perform data transformation
- static_data/ - static file-based data stored in the geocint repository
All these folders and files are removed and recreated each time the geocint pipeline starts. 

After running the pipeline, Makefile will create additional folders and files. These folders are used to store input (in folder), intermediate (mid folder), and output (out folder) data files:
- data/ - file-based input, middle, output data.
	- data/in - all input data, downloaded elsewhere
	- data/in/raster - all downloaded GeoTIFFs
	- data/mid - all intermediate data (retiles, unpacks, reprojections, etc.) which can be removed after
  	each launch
	- data/out - all generated final data (tiles, dumps, unloading for the clients, etc.)
- deploy/ - files - Makefile mark about executing "deploy/..." targets
- logs/ - files - files with targets execution logs
- report/ - folder to store HTML reports.

These folders are not deleted or re-created each time the geocint pipeline runs to avoid rebuilding targets that should not be rebuilt every time (if you want to rebuild some targets chain each time please see How geocint pipeline works in this doc).
You shouldn’t store all your input datasets in data/in/ folder. To make your data storage more organized, you can create additional folders for separate data sources (for example data/in/source_name). This rule also applies to other catalogs.

Also when running the pipeline Makefile will create additional files:
- make.lock - a special file used by start_geocint.sh as a flag to check if a pipeline is running in order not to start a new one until the running pipeline is complete
- make.svg - a file that shows a stored graphical representation of the graph with dependencies of targets

## Geocint open-source installation and first run guide

### Versions

Geocint is an actively developed project, so in the future we could potentially add some new features that could break your pipeline (without the necessary changes on your part).
Therefore, we kindly ask you to use the latest release branch from the geocint-runner repository if you want to be sure that your geocint instance is reliable.
Also, don't set the UPDATE_RUNNER variable to true if you don't want to get the latest updates from branches that are enabled in your local geocint-runner.
These features are available to developers. But you can use master and set the UPDATE_RUNNER and UPDATE_OSM_LOGIC variables to true if you want to make sure you always have the latest version of Geocint.

### Installation

1. Create a working directory for Geocint pipeline. In this directory you will store config.inc.sh file and repositories with code.
2. Create a new user with sudo permissions or use the existing one (the default user is "gis").
3. Clone 3 repositories (geocint-runner, geocint-mapaction-osm, geocint-mapaction) to working directory.
```bash
    cd /your_working_directory/
	git clone https://github.com/konturio/geocint-runner.git
	git clone https://github.com/mapaction/geocint-mapaction-osm
	git clone https://github.com/mapaction/geocint-mapaction

    # to switch to release branch use
	cd /your_working_directory/geocint-runner && git checkout (name of the last release branch)
	cd /your_working_directory/geocint-mapaction-osm && git checkout (name of the last release branch)
	cd /your_working_directory/geocint-mapaction && git checkout (name of the last release branch)
```
4. The geocint pipeline can [send messages](https://api.slack.com/messaging/sending) to the Slack channel.
The Slack integration is an optional part, you can safely skip it and add it later if needed. To set slack integration you should:

* Create a [channel](https://slack.com/help/articles/201402297-Create-a-channel);
* Generate a Slack App and [configure it](https://github.com/kasunkv/slack-notification/blob/master/generate-slack-token.md);
* Add it to your [channel](https://slack.com/help/articles/202035138-Add-apps-to-your-Slack-workspace);
* [Get the Bot User OAuth Token](https://github.com/kasunkv/slack-notification/blob/master/generate-slack-token.md#4-copy-oauth-access-token--use-in-azure-pipelines) n e.g. 'xoxb-111-222-xxxxx'. Bot OAuth Token will be stored in the SLACK_KEY variable in the file config.inc.sh. The angle brackets around your_key are in need to be removed.

5. Copy [config.inc.sh.sample](config.inc.sh.sample) from geocint-runner to working directory and name config.inc.sh.

Then open config.inc.sh and set the necessary values for variables. See comments at this file for details.

6. Run installation:
```shell
	# install cmake if not exists
	sudo apt install -y cmake
	# move to the folder with installation Makefile
	cd /your_working_directory/geocint-runner/scripts/
	# run installation (you should set path to config.inc.sh file)
	make install configuration_file=/your_working_directory/config.inc.sh
	# reload $HOME/.bashrc file
	source ${HOME}/.bashrc

	# restart your server
	sudo reboot
```

7. Set the crontab to autostart the pipeline. 

To set up your crontab to start the pipeline automatically, you need to:
* open crontab `crontab -e`. If you are trying to use crontab for the first time, please read this [guide](https://www.howtogeek.com/101288/how-to-schedule-tasks-on-linux-an-introduction-to-crontab-files)
* add to crontab settings the next lines to run your pipeline every night at midnight (keep in mind, that you should replace "your_working_directory" with your working directory):

`0 0 * * * cd /your_working_directory && mkdir -p geocint && /bin/bash /your_working_directory/geocint-runner/start_geocint.sh > /your_working_directory/geocint/log.txt`
* add the following line to regenerate make.svg every 5 minutes; make.svg is a file with a stored graphical representation of graph with dependencies of targets (gray targets - not built, blue - successfully built, red - not built due to the error)

`*/5 * * * * cd /your_working_directory/geocint/ && profile_make`

* save your changes and exit.

8. Install nginx and make nginx configuration. 

All files and symbolic links which are necessary for geocint web-dashboard are automatically put to /your_working_directory/public_html directory, but you still need to install and configure a web server. We recommend [nginx](https://www.nginx.com/).

Apache is installed by default with Ubuntu, so you may want to disable it.
```shell
	sudo systemctl stop apache2
	sudo systemctl disable apache2
```

Install nginx and allow it to be used in the Ubuntu firewall:
```shell
	sudo apt update
	sudo apt install nginx
	sudo ufw allow "Nginx Full"
```

Create/adjust nginx configuration, e.g. the default one:
```
	sudo nano /etc/nginx/sites-available/default
```

**remember to comment out the root that comes with the default file** on the above path

```bash
# root /var/www/html;
```
the location section should look like this
```
    location / {
        access_log /your_working_directory/domlogs/access.log combined buffer=4k flush=5s;
        error_log /your_working_directory/domlogs/error.log warn;

        root /your_working_directory/public_html;
        try_files $uri $uri/ =404;
```
**root** should point to the public_html subfolder in your geocint working folder, 
*/your_working_directory/public_html* in this example;

For more details on nginx setup refer to the [manual](http://nginx.org/en/docs/beginners_guide.html).

Test configuration and run nginx:
```shell
	sudo nginx -t
	sudo systemctl start nginx
```

### First run

To automatically start the full pipeline, set the preferred time in the crontab installation.
For example, to run the pipeline every night at midnight set

`0 0 * * * cd /your_working_directory && mkdir -p geocint && /bin/bash /your_working_directory/geocint-runner/start_geocint.sh > /your_working_directory/geocint/log.txt`

if you want to run the pipeline manually, then run the next line, but keep in mind, that you should replace "/your_working_directory/" with the directory where you cloned 3 repositories (see point 2 for more information):
```shell
bash /your_working_directory/geocint-runner/start_geocint.sh > /your_working_directory/geocint/log.txt
```

### How to create your custom part of pipeline

You need to create a folder where you will store the custom part of the pipeline (for example `geocint-custom`) and initialize the repository.
The custom part is a git repository (folder) with a set of files necessary to execute the pipeline.
```shell
	mkdir /your_working_directory/geocint-custom
	cd /your_working_directory/geocint-custom && git init
```

The minimum set of files consists of:
- install.sh (use [runner-install.sh](runner-install.sh) from geocint-runner repository as an example, 
this bash script will store installation of your additional dependencies (for example geopandas, if you need it for your pipeline))

create an empty file in your folder and save this code as a `install.sh` file:
```
#!/bin/bash

# Add here your custom intallation instructions
# use runner-install.sh from geocint-runner repository as an example
# Please, use sudo to run commands and -y for apt, for example
# sudo apt install -y osmium-tool

# remove this row afret adding any row with installation
exit 0
```

- Makefile (use [your_make.sample](your_make.sample) from geocint-runner repository as an example how to create new pipeline.

create an empty file in your folder and save this code as a `Makefile` file:
```
## -------------- EXPORT BLOCK ------------------------

# configuration file
file := ${GEOCINT_WORK_DIRECTORY}/config.inc.sh
# Add an export here for each variable from the configuration file that you are going to use in the targets.
export SLACK_CHANNEL = $(shell sed -n -e '/^SLACK_CHANNEL/p' ${file} | cut -d "=" -f 2)
export SLACK_BOT_NAME = $(shell sed -n -e '/^SLACK_BOT_NAME/p' ${file} | cut -d "=" -f 2)
export SLACK_BOT_EMOJI = $(shell sed -n -e '/^SLACK_BOT_EMOJI/p' ${file} | cut -d "=" -f 2)
export SLACK_BOT_KEY = $(shell sed -n -e '/^SLACK_BOT_KEY/p' ${file} | cut -d "=" -f 2)

# these makefiles are stored in geocint-runner and geocint-openstreetmap repositories
# runner_make contains the basic set of targets for creating the project folder structure
# osm_make contains a set of targets for osm data processing
include runner_make osm_make

## ------------- CONTROL BLOCK -------------------------

# replace your_final_target placeholder with the names of final target, that you will use to run pipeline
# you can also add here the names of targets that should not be rebuilt automatically, just when conditions are met or at your request
# to do it just add these names after the colon separated by a space
all: data/out/hello_world.txt ## [FINAL] Meta-target on top of all other targets, or targets on parking.

# by default the clean target is set to serve an update of the OpenStreetMap planet dump during every run
clean: ## [FINAL] Cleans the worktree for the next nightly run. Does not clean non-repeating targets.
	if [ -f data/planet-is-broken ]; then rm -rf data/planet-latest.osm.pbf ; fi
	rm -rf data/planet-is-broken
	profile_make_clean data/planet-latest-updated.osm.pbf

data/out/hello_world.txt: data/out ## Create a simple txt file and say Hello World!
	# this target will create /your_working_directory/geocint/data/out/hello_world.txt file with Hello World! line inside
	echo "Hello World!" >> $@

```

## How geocint pipeline works

### How start_geocint.sh works

After start_geocint.sh is run, it imports the variables from the configuration file /your_working_directory/config.inc.sh. 
It will then check the update flags in /your_working_directory/config.inc.sh and git pull the repositories that have the flag set to “true”.
Then bash will check if /your_working_directory/geocint/make.lock file exists.
If /your_working_directory/geocint/make.lock file not exists bash will merge geocint-runner, geocint-openstreetmap and your custom repository into one folder /your_working_directory/geocint.
After these events are completed, start_geocint.sh will launch the targets specified in the $RUN_TARGETS variable. The last step is to create/update the make.svg file containing the dependency graph.

### How to write targets

You can read more about writing targets in the official [GNU Make manual](https://www.gnu.org/software/make/manual/make.html#toc-Writing-Rules)

The name of your target will be the name of the file which Make-profiler will use to define the timestamps when the target was executed. If the result of the target execution is a file - the target should be named as this file. If as the result of target execution you don't create a new file, please add `touch $@` line at the end of your target to create an empty file with the same name as a target (`$@` is the equivalent of the name of the target containing it).
For example, target from your_make.sample:
```
deploy/s3/fire_stations: data/out/fire_stations/fire_stations_h3_r8_count.gpkg.gz | deploy/s3 ## deploy/s3 is a dependency from geocint-runner makefile
    aws s3 cp data/out/fire_stations/fire_stations_h3_r8_count.gpkg.gz \
   	 s3://your_s3_bucket/fire_stations_h3_r8_count.gpkg.gz \
   	 --profile your_s3_profile \
   	 --acl public-read
    touch $@
```
As a result of this target execution, we don't have a file, which means we have to execute the `touch $@` command at the end. 
This command will create an empty deploy/s3/fire_stations file whose creation timestamp will be used by Make-profiler.

If you want to rebuild some targets in the chain each time when you run the pipeline, you must add the initial target of this chain to the clean target.
For example, you might have a target’s chain like (here is a simple chain of targets, just the target’s name):
```
data/in/some.tiff: | data/in ## initial target, download input data
data/mid/data_tiff.csv: data/in/some.tiff | data/mid## extract data from raster to intermediate file
db/table/table_from_csv: data/mid/data_tiff.csv | db/table ## load data from CSV to database
data/out/output.geojson.gz: db/table/table_from_csv | data/out ## extract data from database to output file
```
If you want to rebuild this chain of targets each time you run the pipeline, you should add data/in/some.tiff target as an argument for profile_make_clean instruction in the clean target (see the code below). 
```
# by default the clean target is set to serve an update of the OpenStreetMap planet dump during every run
clean: ## [FINAL] Cleans the worktree for next nightly run. Does not clean non-repeating targets.
	if [ -f data/planet-is-broken ]; then rm -rf data/planet-latest.osm.pbf ; fi
	rm -rf data/planet-is-broken
	profile_make_clean data/planet-latest-updated.osm.pbf data/in/some.tiff
```
It means that before each run make-profiler will remove data/in/some.tiff if it exists and rebuild the data and all the targets, that are in the list of dependencies 
(will check dependencies recursively).

If you do not want to rebuild this chain, just make sure that your chain doesn’t depend on targets from the clean target. This method can be useful when you have a large dataset that has not been updated recently and requires heavy and time-consuming pre-processing. In such a case, you'd probably want to prepare the data and load it to the database once not repeating this work without changing the input data.
But! Keep in mind, that dependencies are inherited recursively, even if you don’t put data/in/some.tiff in the data/out/output.geojson.gz dependencies list, it will be data/out/output.geojson.gz’s dependency. It means that these two lines are equivalent:
```
data/out/output.geojson.gz: db/table/table_from_csv
data/out/output.geojson.gz: data/in/some.tiff db/table/table_from_csv db/table/table_from_csv | data/out
```
You can read more about target's dependencies(prerequisites) in the official [GNU Make manual](https://www.gnu.org/software/make/manual/make.html#Prerequisite-Types)

### How make.lock file work

`/your_working_directory/geocint/make.lock` is a special temporary file that is created automatically after the pipeline starts and is deleted after the pipeline ends.
Bash uses the make.lock file to avoid duplicating a running pipeline.

### How to analyse build time for targets

Logs for every build are stored in `/your_working_directory/geocint/logs`

This command can show lastN {*Total times in ms*} for some {*tablename*} ordered by date

```bash
find /your_working_directory/geocint/logs -type f -regex ".*/db/table/osm_admin_boundaries/log.txt" -mtime -50 -printf "%T+ %p; " -exec awk '/Time:/ {sum += $4} END {print sum/60000 " min"}' '{}' \; | sort
```

`-mtime -50` - collects every row from 50 days ago till now

`-regex ".*/db/table/osm_admin_boundaries/log.txt"` - change `osm_admin_boundaries` to your {*tablename*}


## Make-profiler

Make-profiler is used as a linter and preprocessor for Makefile that outputs a network diagram and an html report of what is getting built, when, and why. 
The output chart (by default make.svg) & html report allows seeing what went wrong and quickly getting to logs. https://github.com/konturio/make-profiler  
After the pipeline run, make_profiler will create make.svg, make_profile.db & a json file to be used on report page.  
Both svg file and report can be reached on web from http://your_ip_or_domain/make.svg & http://your_ip_or_domain/  
While report json generation make_profile.db, logs and relevant folders are checked and result json file is created including last pipeline status and information about every target. This json is used on report page.  
  
Make-profile report features:
- Total number of targets finished, in progress and failed is reported.    
- Targets finished, in progress and failed can be seen on white, yellow and red colors.   
- Tasks can be filtered and only desired ones can be seen.  
- Status duration, last completed date, status date & logs about task can be reached for every task.  
- Report can be sorted with any of task information.  
  
Make-profile svg features:
- SVG build overview;
- Critical Path is highlighted;
- Inline pictures-targets into build overview;
- Logs for each target are marked with timestamps;
- Distinguish a failed target execution from forgotten touch;
- Navigate to the last run's logs from each target directly from the call graph;
- Support of self-documented Makefiles according to http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html

Example usage
```shell
sudo apt install python3-pip graphviz gawk
sudo pip3 install https://github.com/konturio/make-profiler/archive/master.zip

cd your_project
profile_make -h                 # have a look at help

profile_make                    # generate an overview graph without profiling data
xdg-open make.svg               # have a look at the call graph

profile_make_clean target       # mark target with children as not yet executed

profile_make_lint               # validate Makefile to find orphan targets
profile_make -j -k target_name  # run a target, record execution times and logs
xdg-open make.svg               # have a look at the call graph with timing data

profile_make -a 2022-05-01      # generate an overview graph with the full target time only after the specified date
```

## Best practices of using

There are a few simple rules, follow them to avoid troubles during the creation of your own pipeline:
* Don’t create targets with a name that already exists in Makefile from geocint-runner repository, osm-make Makefile, from geocint-openstreetmap repository or in your own Makefile;
* Always add a short comment to your target (explain what it does) - it’s a requirement;
* Don’t use double quotes in comments (make-profile will be broken);
* Try to avoid views and materialized views;
* Complex python scripts should become less complex bash+sql scripts;
* Make sure you have source data always available. Do not store it locally on server - add a target to download data from S3 at least (you can still store data in a special folder - /static_data, but try to avoid storing important data without a remote backup);
* Try to run the pipeline at least once on your test branch, or create a simple short makefile for test_* tables in a separate folder and run it, avoiding the effect on running the pipeline;
* Make sure your scripts (especially bash, ansible) work as a part of Makefile, not only by themselves. For example, you have to use $$ instead of $ to access a variable inside Makefile;
* Check idempotence: how will it run the first time? Second time? 100 times?;
* Be careful with the copying and removing of non-existing yet files: it should be forced operation;
* Be careful with deleting or renaming functions and procedures, especially when you change the number or order of parameters;
* Try to use drop/alter database_object with IF EXIST option;
* Define: does your target need to be launched every day? Don’t forget to put it into the Clean one. Or make it manually (see Cache invalidation);
* When replacing a target with another, ensure that the unused one has been deleted from all locations;
* Updates on tables should be a part of the target, where these tables are created, for not updating something twice;
* When you add a new functionality and modify existing targets do cache invalidation: manual cleaning of currently updated but existing targets;
* Delete local/S3 files and DB objects that you don’t need anymore.

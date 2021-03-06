--
-- Histogram, entire dataset.  You will not be able to run this locall. :-)
-- I used 18 m3.xlarge EMR servers, job completed in about 18 minutes.  You
-- could probably go with fewer and better optimize spending.
--
register ./pigtest/myudfs.jar
raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/btc-2010-chunk-*' USING TextLoader as (line:chararray);
ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);

subjects = group ntriples by (subject) PARALLEL 50;

count_by_subject = foreach subjects generate flatten($0), COUNT($1) as count PARALLEL 50;

-- Produce unique tuples.
histogram = group count_by_subject by (count) PARALLEL 50;
-- emit output.
store histogram into '/user/hadoop/p6' using PigStorage();


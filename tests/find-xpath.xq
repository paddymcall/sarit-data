xquery version "3.1";


import module namespace request="http://exist-db.org/xquery/request";
import module namespace util="http://exist-db.org/xquery/util";
(: import module namespace config="http://sarit.indology.info/sarit-data/exist/config"; :)
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function local:main() as node()?
{
	(: figure out the name of the index file :)
	let $index :=
	if (request:get-parameter("index", ()))
	then request:get-parameter("index", ())
	else "saritcorpus.xml"
	
	let $rawPath := system:get-module-load-path()	
	(: revision defaults to master :)
	let $revision :=
	if (request:get-parameter("revision", ()))
	then request:get-parameter("revision", ())
	else "master"

	(: collect this into a root document :)
	let $root := $rawPath || "/../" || $revision || "/" || $index
	
	(: the path to look up :)
	let $path :=
	if (request:get-parameter("path",()))
	then request:get-parameter("path",())
	else "/"

	return
	<identifier>
	<index>{$index}</index>
	<rawPath>{$rawPath}</rawPath>
	<root>{$root}</root>
	<revision>{$revision}</revision>
	<path>{$path}</path>
	</identifier>
	};


<result>{ local:main() }</result>
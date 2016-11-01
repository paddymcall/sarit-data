(: xquery to be run against saritcorpus.xml :)
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xi="http://www.w3.org/2001/XInclude";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:omit-xml-declaration "yes";
string-join(//xi:include[@href]/@href/string(), ",")

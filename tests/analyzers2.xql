xquery version "3.0";

(: from lucene tests :)

module namespace analyze="http://exist-db.org/xquery/lucene/test/analyzers";

declare namespace test="http://exist-db.org/xquery/xqsuite";

(: the sarit-slp1 analyzer developed by claudius :)
declare variable $analyze:XCONF1 :=
    <collection xmlns="http://exist-db.org/collection-config/1.0">
        <index xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <lucene>
        <analyzer class="org.apache.lucene.analysis.core.StandardAnalyzer"/>
	<!-- parser makes no difference -->
        <!-- <parser class="org.apache.lucene.analysis.core.StandardAnalyzer"/> -->
        <text qname="p"/>
        </lucene>
        </index>
        <triggers>
            <trigger class="org.exist.extensions.exquery.restxq.impl.RestXqTrigger"/>
        </triggers>
    </collection>;


(: simple dumb whitespace analyzer, for sake of comparison :)
declare variable $analyze:XCONF2 :=
    <collection xmlns="http://exist-db.org/collection-config/1.0">
        <index xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <lucene>
        <analyzer class="org.apache.lucene.analysis.core.WhitespaceAnalyzer"/>
	<parser class="org.apache.lucene.analysis.core.WhitespaceAnalyzer"/>
                <text qname="p"/>
            </lucene>
        </index>
        <triggers>
            <trigger class="org.exist.extensions.exquery.restxq.impl.RestXqTrigger"/>
        </triggers>
    </collection>;


declare
    %test:setUp
function analyze:setup() {
    let $testCol := xmldb:create-collection("/db", "lucenetest")
    let $testCol1 := xmldb:create-collection("/db/lucenetest", "test1")
    let $testCol2 := xmldb:create-collection("/db/lucenetest", "test2")
    let $confCol := xmldb:create-collection("/db/system/config/db", "lucenetest")
    let $confCol1 := xmldb:create-collection("/db/system/config/db/lucenetest", "test1")
    let $confCol2 := xmldb:create-collection("/db/system/config/db/lucenetest", "test2")
    let $testdoc :=
	<test>
	<p id="upper">AAAAABBBBBCCCCC</p>
	<p id="lower">aaaaabbbbbccccc</p>
	<p id="mixed">aaaAAbbbBBcccCC</p>
	<p>Eins zwei drei vier zwei fünf sechs.</p>
	</test>
    return (
        xmldb:store($confCol1, "collection.xconf", $analyze:XCONF1),
        xmldb:store($testCol1, "test.xml", $testdoc),
        xmldb:store($confCol2, "collection.xconf", $analyze:XCONF2),
        xmldb:store($testCol2, "test.xml", $testdoc)
    )
};

(: declare :)
(:    %test:tearDown :)
(: function analyze:tearDown() { :)
(:    xmldb:remove("/db/lucenetest"), :)
(:    xmldb:remove("/db/system/config/db/lucenetest") :)
(: }; :)



declare 
    %test:args("AAAA*")
    %test:assertEquals("<p id='upper'>AAAAABBBBBCCCCC</p>", "<p id='lower'>aaaaabbbbbccccc</p>", "<p id='mixed'>aaaAAbbbBBcccCC</p>")
    %test:args("aaaa*")
%test:assertEquals("<p id='upper'>AAAAABBBBBCCCCC</p>", "<p id='lower'>aaaaabbbbbccccc</p>", "<p id='mixed'>aaaAAbbbBBcccCC</p>")
    %test:args("AAaaA*")
    %test:assertEquals("<p id='upper'>AAAAABBBBBCCCCC</p>", "<p id='lower'>aaaaabbbbbccccc</p>", "<p id='mixed'>aaaAAbbbBBcccCC</p>")
function analyze:case-insensitive-default($term as xs:string) {
	collection("/db/lucenetest/test1")//p[ft:query(., $term)]
};


declare 
    %test:args("AAAA*")
%test:assertEquals("<p id='upper'>AAAAABBBBBCCCCC</p>", "<p id='lower'>aaaaabbbbbccccc</p>", "<p id='mixed'>aaaAAbbbBBcccCC</p>")
    %test:args("aaaa*")
%test:assertEquals("<p id='upper'>AAAAABBBBBCCCCC</p>", "<p id='lower'>aaaaabbbbbccccc</p>", "<p id='mixed'>aaaAAbbbBBcccCC</p>")
    %test:args("AAaaA*")
    %test:assertEquals("<p id='upper'>AAAAABBBBBCCCCC</p>", "<p id='lower'>aaaaabbbbbccccc</p>", "<p id='mixed'>aaaAAbbbBBcccCC</p>")
function analyze:case-insensitive-filter-rewrite-no($term as xs:string) {
	let $options := <options>
        <filter-rewrite>no</filter-rewrite>
        </options>
	return collection("/db/lucenetest/test1")//p[ft:query(., $term, $options)]
};



declare 
    %test:args("AAAA*")
%test:assertEquals("<p id='upper'>AAAAABBBBBCCCCC</p>", "<p id='lower'>aaaaabbbbbccccc</p>", "<p id='mixed'>aaaAAbbbBBcccCC</p>")
    %test:args("aaaa*")
%test:assertEquals("<p id='upper'>AAAAABBBBBCCCCC</p>", "<p id='lower'>aaaaabbbbbccccc</p>", "<p id='mixed'>aaaAAbbbBBcccCC</p>")
    %test:args("AAaaA*")
    %test:assertEquals("<p id='upper'>AAAAABBBBBCCCCC</p>", "<p id='lower'>aaaaabbbbbccccc</p>", "<p id='mixed'>aaaAAbbbBBcccCC</p>")
function analyze:case-insensitive-filter-rewrite-yes($term as xs:string) {
	let $options := <options>
        <filter-rewrite>yes</filter-rewrite>
        </options>
	return collection("/db/lucenetest/test1")//p[ft:query(., $term, $options)]
};


declare 
    %test:args("AAAA*")
    %test:assertEquals("<p id='upper'>AAAAABBBBBCCCCC</p>")
    %test:args("AAAAABBBBBCCCCC")
    %test:assertEquals("<p id='upper'>AAAAABBBBBCCCCC</p>")
    %test:args("aaaa*")
    %test:assertEquals("<p id='lower'>aaaaabbbbbccccc</p>")
    %test:args("aaaAA*")
    %test:assertEquals("<p id='mixed'>aaaAAbbbBBcccCC</p>")
    %test:args("aaaAAbbbBBcccCC")
    %test:assertEquals("<p id='mixed'>aaaAAbbbBBcccCC</p>")
function analyze:case-sensitive-default($term as xs:string) {
	collection("/db/lucenetest/test2")//p[ft:query(., $term)]
};


declare 
    %test:args("AAAA*")
    %test:assertEquals("<p id='upper'>AAAAABBBBBCCCCC</p>")
    %test:args("aaaa*")
    %test:assertEquals("<p id='lower'>aaaaabbbbbccccc</p>")
    %test:args("aaaAA*")
    %test:assertEquals("<p id='mixed'>aaaAAbbbBBcccCC</p>")
function analyze:case-sensitive-filter-rewrite-no($term as xs:string) {
	let $options := <options>
        <filter-rewrite>no</filter-rewrite>
        </options>
	return collection("/db/lucenetest/test2")//p[ft:query(., $term, $options)]
};



declare 
    %test:args("AAAA*")
    %test:assertEquals("<p id='upper'>AAAAABBBBBCCCCC</p>")
    %test:args("aaaa*")
    %test:assertEquals("<p id='lower'>aaaaabbbbbccccc</p>")
    %test:args("aaaAA*")
    %test:assertEquals("<p id='mixed'>aaaAAbbbBBcccCC</p>")
function analyze:case-sensitive-filter-rewrite-yes($term as xs:string) {
	let $options := <options>
        <filter-rewrite>yes</filter-rewrite>
        </options>
	return collection("/db/lucenetest/test2")//p[ft:query(., $term, $options)]
};

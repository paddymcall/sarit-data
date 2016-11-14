xquery version "3.0";

(: from lucene tests :)

module namespace analyze="http://exist-db.org/xquery/lucene/test/analyzers";

declare namespace test="http://exist-db.org/xquery/xqsuite";

(: the sarit-slp1 analyzer developed by claudius :)
declare variable $analyze:XCONF1 :=
    <collection xmlns="http://exist-db.org/collection-config/1.0">
        <index xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <lucene>
        <analyzer class="de.unihd.hra.libs.java.luceneTranscodingAnalyzer.TranscodingAnalyzer"/>
	<!-- parser makes no difference -->
        <!-- <parser class="de.unihd.hra.libs.java.luceneTranscodingAnalyzer.TranscodingAnalyzer"/> -->
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
	<p>yuktaḥ</p>
	<p>yuktā</p>
	<p>sarvam ayuktam</p>
	<p>bhavatu</p>
	<p>bhāvaḥ</p>
	<p>युक्तः</p>
	<p>युक्ता</p>
	<p>सर्वमयुक्तम्</p>
	<p>भवतु</p>
	<p>भावः</p>
	</test>
    return (
        xmldb:store($confCol1, "collection.xconf", $analyze:XCONF1),
        xmldb:store($testCol1, "test.xml", $testdoc),
        xmldb:store($confCol2, "collection.xconf", $analyze:XCONF2),
        xmldb:store($testCol2, "test.xml", $testdoc)
    )
};

declare
   %test:tearDown
function analyze:tearDown() {
   xmldb:remove("/db/lucenetest"),
   xmldb:remove("/db/system/config/db/lucenetest")
};

declare 
    %test:args("yukta")
    %test:assertEmpty
    %test:args("yukto")
    %test:assertEmpty
    %test:args("yuktā")
    %test:assertEquals("<p>yuktā</p>", "<p>युक्ता</p>")
    %test:args("yuktaḥ")
    %test:assertEquals("<p>yuktaḥ</p>", "<p>युक्तः</p>")
function analyze:slp1-simple-terms($term as xs:string) {
    collection("/db/lucenetest/test1")//p[ft:query(., $term)]
};

declare 
    %test:args("yukta*")
    %test:assertEquals("<p>yuktaḥ</p>", "<p>युक्तः</p>")
    %test:args("yukt*")
    %test:assertEquals("<p>yuktaḥ</p>", "<p>yuktā</p>", "<p>युक्तः</p>", "<p>युक्ता</p>")
    %test:args("bh?v*")
    %test:assertEquals("<p>bhavatu</p>", "<p>bhāvaḥ</p>", "<p>भवतु</p>", "<p>भावः</p>")
    %test:args("yuktā*")
    %test:assertEquals("<p>yuktā</p>", "<p>युक्ता</p>")
    %test:args("yuktA*")
    %test:assertEquals("<p>yuktā</p>", "<p>युक्ता</p>")
    %test:args("युक्ता*")
    %test:assertEquals("<p>yuktā</p>", "<p>युक्ता</p>")
    %test:args("y?ktā*")
    %test:assertEquals("<p>yuktā</p>", "<p>युक्ता</p>")
function analyze:slp1-wildcards($term as xs:string) {
    collection("/db/lucenetest/test1")//p[ft:query(., $term)]
};


declare 
    %test:args("*yukta*")
    %test:assertEquals("<p>yuktaḥ</p>", "<p>sarvam ayuktam</p>", "<p>युक्तः</p>", "<p>सर्वमयुक्तम्</p>")
    %test:args("*yukt*")
    %test:assertEquals("<p>yuktaḥ</p>", "<p>yuktā</p>", "<p>sarvam ayuktam</p>", "<p>युक्तः</p>", "<p>युक्ता</p>", "<p>सर्वमयुक्तम्</p>")
    %test:args("*yuktā*")
    %test:assertEquals("<p>yuktā</p>", "<p>युक्ता</p>")
    %test:args("*y?ktā*")
    %test:assertEquals("<p>yuktā</p>", "<p>युक्ता</p>")
function analyze:slp1-wildcards-leading($term as xs:string) {
	let $options := <options>
        <default-operator>and</default-operator>
        <phrase-slop>0</phrase-slop>
        <leading-wildcard>yes</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
        </options>
	return collection("/db/lucenetest/test1")//p[ft:query(., $term, $options)]
};


(: declare  :)
(:     %test:args("russelsheim") :)
(:     %test:assertEquals(1) :)
(:     %test:args("rüsselsheim") :)
(:     %test:assertEquals(1) :)
(:     %test:args("maori") :)
(:     %test:assertEquals(1) :)
(:     %test:args("Māori") :)
(:     %test:assertEquals(1) :)
(: function analyze:diacrictics($term as xs:string) { :)
(:     count(collection("/db/lucenetest/test2")//p[ft:query(., $term)]) :)
(: }; :)

(: run some simple searches with the whitespace analyzer, just for sanity reasons :)

declare 
    %test:args("*yukta*")
    %test:assertEquals("<p>yuktaḥ</p>", "<p>sarvam ayuktam</p>")
    %test:args("*युक्त*")
    %test:assertEquals("<p>युक्तः</p>", "<p>युक्ता</p>", "<p>सर्वमयुक्तम्</p>")
    %test:args("*yukt*")
    %test:assertEquals("<p>yuktaḥ</p>", "<p>yuktā</p>", "<p>sarvam ayuktam</p>")
    %test:args("*yuktā*")
    %test:assertEquals("<p>yuktā</p>")
    %test:args("*y?ktā*")
    %test:assertEquals("<p>yuktā</p>")
function analyze:whitespace-analyzer-wildcards-leading($term as xs:string) {
	let $options := <options>
        <default-operator>and</default-operator>
        <phrase-slop>0</phrase-slop>
        <leading-wildcard>yes</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
        </options>
	return collection("/db/lucenetest/test2")//p[ft:query(., $term, $options)]
};

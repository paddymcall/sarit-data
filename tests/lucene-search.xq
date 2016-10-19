xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";

(: let $query := "gṛhīt* AND tatra" :)
(: let $query := <query><bool><wildcard occur="must">tatr*</wildcard><wildcard occur="must">yatr*</wildcard></bool></query> :)
let $query := <query>
<bool>
<wildcard occur="must">suKa*</wildcard>
<wildcard occur="must">duHKa*</wildcard>
</bool>
</query>


(: this could be useful, but doesn't change anything for the boolean search? :)
let $options :=
    <options>
        <default-operator>and</default-operator>
        <leading-wildcard>yes</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>

let $hits := collection("/db/apps/sarit-data/data/")//tei:l[ft:query(., $query(: , $options :))]

return
<div>
<head>{count($hits)} results for {$query//text()}</head>
<results hits-number="{count($hits)}">
{
	for $hit in $hits
	order by ft:score($hit) descending
	return
	<result>
	<content>{$hit}</content>
	<score>{ft:score($hit)}</score>
	<path>dunno, please help</path>
	</result>
}
</results>
</div>
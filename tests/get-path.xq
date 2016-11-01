import module namespace functx = "http://www.functx.com";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(: various ways to get path to nodes: 

- functx: works, but it's slow; maybe ignores namespaces (fixed in definition below)?


- util:node-xpath: not sure if these are really unambiguous? --> test!
"@xmlns:" looks suspicious?)

:)

(: see http://www.xqueryfunctions.com/xq/functx_index-of-node.html :)
(: declare function functx:index-of-node :)
(:   ( $nodes as node()* , :)
(:     $nodeToFind as node() )  as xs:integer* { :)

(:   for $seq in (1 to count($nodes)) :)
(:   return $seq[$nodes[$seq] is $nodeToFind] :)
(:  } ; :)

(: see http://www.xqueryfunctions.com/xq/functx_path-to-node-with-pos.html :)
(: declare function functx:path-to-node-with-pos :)
(:   ( $node as node()? )  as xs:string { :)
(: 	string-join( :)
(: 		for $ancestor in $node/ancestor-or-self::* :)
(: 		let $sibsOfSameName := $ancestor/../*[name() = name($ancestor)] :)
(: 		return concat(name($ancestor), :)
(: 			if (count($sibsOfSameName) <= 1) :)
(: 			then '' :)
(: 			else concat( :)
(: 				'[',functx:index-of-node($sibsOfSameName,$ancestor),']')) :)
(: 		, '/') :)
(: 	} ; :)



let $query := <query>
<bool>
<wildcard occur="must">suKa*</wildcard>
<wildcard occur="must">duHKa*</wildcard>
<wildcard occur="must">sad*</wildcard>
</bool>
</query>

let $hits := collection("/db/soup")//tei:l[ft:query(., $query)]

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
	<path>{util:node-xpath($hit)}</path>
	<path>{functx:path-to-node-with-pos($hit)}</path>
	<exist-resource-id>{util:absolute-resource-id($hit)}</exist-resource-id>
	<exist-node-id>{util:node-id($hit)}</exist-node-id>
	(: in eXist resource-id (~ document-id) + node-id specify absolute position :)
	<reverse>{
		functx:path-to-node-with-pos(
			util:node-by-id(
				util:get-resource-by-absolute-id(util:absolute-resource-id($hit)),
				util:node-id($hit)
			)
		)
	}
	</reverse>
	</result>
}
</results>
</div>
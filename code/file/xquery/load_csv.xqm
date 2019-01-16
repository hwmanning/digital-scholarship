xquery version "3.1";

module namespace vudssccsv = 'https://github.com/HeardLibrary/digital-scholarship/tree/master/code/csv';

(: These functions call functions that are particular to BaseX.  You will need to modifiy it for other XQuery processors. :)

(: These functions call functions that are particular to BaseX.  You will need to modifiy it for other XQuery processors. :)

(: When the value of $baseLocation is "c", the base URI is set to be the current working directory (usually defaults to the user directory)
   When the value of $baseLocation is "b", the base URI is set to the directory from which the script was invoked/saved.
   When the value of $baseLocation is any other value, the base URI is set to the empty string; i.e. the relative path is the absolute path. :)

(: $relativePath should contain the path from the chosen base directory to, and including the file name.  Slashes can be either direction.
   If the file is in the chosen base directory, then $relativePath is simply the file name (including any extension). :)

(: function from http://www.xqueryfunctions.com/xq/functx_trim.html :)
declare function vudssccsv:trim
  ( $arg as xs:string? )  as xs:string {

   replace(replace($arg,'\s+$',''),'^\s+','')
 } ;
 
declare function vudssccsv:loadCsv($baseLocation as xs:string, $relativePath as xs:string, $delimiter as xs:string) as element()
{
(: This function reads from a CSV file. :)

(: The returned element is an XML root element node with the following pattern:

<csv>
  <record>
    <firstColumnHeader>cellValue</firstColumnHeader>
    <secondColumnHeader>cellValue</secondColumnHeader>
  </record>
</csv>

where firstColumnHeader, etc. is the name of the header in the first column in the table and cellValue is the value in that column for that record.  Note: column headers must be valid XML element names, so no initial numerals, no spaces, etc. :)

(: $delimiter is typically a comma "," but may be other characters depending on the file.  For tab delimited files, use "&#9;" :)

let $baseUri :=
  switch ($baseLocation)
    case "c" return file:current-dir()
    case "b" return file:base-dir()
    default return ""

(: If it's a Windows file system, replace backslashes with forward slashes.  Otherwise, nothing happens. :)
let $path := $baseUri||fn:replace($relativePath,"\\","/")

let $csvDoc := file:read-text($path)
let $xmlDoc := csv:parse($csvDoc, map { 'header' : true(),'separator' : $delimiter })

return $xmlDoc/csv
};

declare function vudssccsv:loadTextList($baseLocation as xs:string, $relativePath as xs:string) as xs:string*
{
(: This function reads from a text file where items are separated by newlines.  A sequence of strings is returned. :)

let $baseUri :=
  switch ($baseLocation)
    case "c" return file:current-dir()
    case "b" return file:base-dir()
    default return ""

(: If it's a Windows file system, replace backslashes with forward slashes.  Otherwise, nothing happens. :)
let $path := $baseUri||fn:replace($relativePath,"\\","/")

let $textDoc := file:read-text($path)
let $stringSequence := tokenize(vudssccsv:trim($textDoc),'\n') (: get rid of any trailing newlines :)

return $stringSequence
};

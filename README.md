# ReOrder
A Script that re-orders the fields in a SFM record

## How to use the script
 * copy the script and .ini file into a work directory
 * edit the .ini file for the old record marker and list of output SFMs in the new order.

## Some things to note
 * Uses the op_deopl stub
 * Assumes that the all fields are single line.

### Sanity check on the input file
If you change the record marker (i.e. the old record marker isn't the first in the new order list -- usually \\lx ). Check that each record has one and only one instance of the new record marker. An easy way to do that is to modify the opl.pl script to use the old marker and check if the new record marker occurs exactly once. For example, if the file record marker is \\ge and the \\lx field is being moved to the front of the record, You could do this:

````bash
perl -pe 's/lx/ge/' opl.pl >geopl.pl
perl -pf geopl.pl InFile.db |grep -v '\\lx '
# should be no SFM records (There could be Toolbox header records or initial blank lines)
perl -pf geopl.pl InFile.db |grep -c '\\lx .*\\lx '
# The script will print all the records with more than one \\lx field
````

## How the script works
This script accepts a list of SFMs and re-orders the SFM fields in each record into the list order.
  * Process each marker in the new order list in reverse order
      * group all the fields of the current marker together
      * delete the fields from the input record
      * copy the group to the front of the output line.
   * When the markers have been processed, add the unmatched text left over in the input line to the end of the output line.

 ## Bugs & Improvements
 * If you have fields that are interspersed (eg multiple \xv & \xe pairs) do it in a separate script
 * the sanity check could be part of the script but shouldn't be.
 * It doesn't really have to be done in reverse order. If you're pulling out matches in groups separate with input & output lines, they can be done in first to last order, adding the extracted items to the end of the output line.

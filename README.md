# ReOrder
A Script that re-orders the fields in a SFM record
 * Uses the op_deopl stub

This script accepts a list of SFMs and re-orders the SFM fields in each record into the list order. 
  * Processing each marker in the list in reverse order
      *  moves all the fields of the current marker to the front of the output line
      * deletes the field from the input record.
   * When the markers have been processed, all the unmatched text is added to the end of the output line.


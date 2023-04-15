# ReOrder
A Script that re-orders the fields in a SFM record
 * Uses the op_deopl stub
 * Assumes that the all fields are single line.

This script accepts a list of SFMs and re-orders the SFM fields in each record into the list order.
  * Processing each marker in the list in reverse order
      * groups all the fields of the current marker together
      * deletes the fields from the input record.
      * copies the group to the front of the output line.
   * When the markers have been processed, add the unmatched text to the end of the output line.

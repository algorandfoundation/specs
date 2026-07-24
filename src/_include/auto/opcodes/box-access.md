| OPCODE | DESCRIPTION |
| :-: | :---------- |
| `box_create` | create a box named A, of length B. Fail if the name A is empty or B exceeds 32,768. Returns 0 if A already existed, else 1 |
| `box_extract` | read C bytes from box A, starting at offset B. Fail if A does not exist, or the byte range is outside A's size. |
| `box_replace` | write byte-array C into box A, starting at offset B. Fail if A does not exist, or the byte range is outside A's size. |
| `box_splice` | set box A to contain its previous bytes up to index B, followed by D, followed by the original bytes of A that began at index B+C. |
| `box_del` | delete box named A if it exists. Return 1 if A existed, 0 otherwise |
| `box_len` | X is the length of box A if A exists, else 0. Y is 1 if A exists, else 0. |
| `box_get` | X is the contents of box A if A exists, else ''. Y is 1 if A exists, else 0. |
| `box_put` | replaces the contents of box A with byte-array B. Fails if A exists and len(B) != len(box A). Creates A if it does not exist |
| `box_resize` | change the size of box named A to be of length B, adding zero bytes to end or removing bytes from the end, as needed. Fail if the name A is empty, A is not an existing box, or B exceeds 32,768. |
| `app_box_create` | create a box named B, of length C, for app A. Fail if the name B is empty or C exceeds 32,768. Returns 0 if B already existed, else 1 |
| `app_box_extract` | read D bytes from box B of app A, starting at offset C. Fail if box B does not exist, or the byte range is outside B's size. |
| `app_box_replace` | write byte-array D into box B of app A, starting at offset C. Fail if box B does not exist, or the byte range is outside B's size. |
| `app_box_del` | delete box named B of app A if it exists. Return 1 if B existed, 0 otherwise |
| `app_box_len` | X is the length of box B of app A if B exists, else 0. Y is 1 if B exists, else 0. |
| `app_box_get` | X is the contents of box B of app A if B exists, else ''. Y is 1 if B exists, else 0. |
| `app_box_put` | replaces the contents of box B of app A with byte-array C. Fails if B exists and len(C) != len(box B). Creates B if it does not exist |
| `app_box_splice` | set box B of app A to contain its previous bytes up to index C, followed by E, followed by the original bytes of B that began at index C+D. |
| `app_box_resize` | change the size of box named B of app A to be of length C, adding zero bytes to end or removing bytes from the end, as needed. Fail if the name B is empty, B is not an existing box, or C exceeds 32,768. |

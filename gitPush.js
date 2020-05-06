"git branch -r" // list remote
"git rev-parse --abbrev-ref HEAD" // current branch

/* PSEUDOCODE
 * if $current not in remote
 *   git push -u origin $current
 * else
 *   git push
 * end
 */


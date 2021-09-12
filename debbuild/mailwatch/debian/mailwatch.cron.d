#
# Regular cron jobs for the mailwatch package
#
0 4	* * *	root	[ -x /usr/bin/mailwatch/tools/Cron_jobs/mailwatch_quarantine_report.php ] && /usr/bin/mailwatch/tools/Cron_jobs/mailwatch_quarantine_report.php >/dev/null 2>&1
5 4	* * *	root	[ -x /usr/bin/mailwatch/tools/Cron_jobs/mailwatch_quarantine_maint.php ] && /usr/bin/mailwatch/tools/Cron_jobs/mailwatch_quarantine_maint.php >/dev/null 2>&1
10 4	* * *	root	[ -x /usr/bin/mailwatch/tools/Cron_jobs/mailwatch_db_clean.php ] && /usr/bin/mailwatch/tools/Cron_jobs/mailwatch_db_clean.php >/dev/null 2>&1
0 4	1 * *	root	[ -x /usr/bin/mailwatch/tools/Cron_jobs/mailwatch_geoip_update.php ] && sleep $[( $RANDOM % 3600)+1]s && /usr/bin/mailwatch/tools/Cron_jobs/mailwatch_geoip_update.php >/dev/null 2>&1
0 4	1 * *	root	[ -x /usr/bin/mailwatch/tools/Cron_jobs/mailwatch_update_sarules.php ] && sleep $[( $RANDOM % 3600)+1]s && /usr/bin/mailwatch/tools/Cron_jobs/mailwatch_update_sarules.php >/dev/null 2>&1
*/5 *	* * *	root	[ -x /usr/bin/mailwatch/tools/MailScanner_rule_editor/msre_reload.sh ] && /usr/bin/mailwatch/tools/MailScanner_rule_editor/msre_reload.sh >/dev/null 2>&1

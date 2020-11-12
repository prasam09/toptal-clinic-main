/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Wrapper to Google Calendar change event published	
*
* Used in GoogleCalendarSyncAPI
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
global class GoogleCalendarSyncWrapper {
    global String googChannelID; // channel-ID-value
    global String googChannelToken; // channel-token-value
    global String googChannelExpiration; // expiration-date-and-time // In human-readable format; present only if channel expires.
    global String googResourceID; // identifier-for-the-watched-resource
    global String googResourceURI; // version-specific-URI-of-the-watched-resource
    global String googResourceState; // sync
    global String googMessageNumber; // 1
}
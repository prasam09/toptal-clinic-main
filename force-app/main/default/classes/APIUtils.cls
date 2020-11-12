/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* All Generic functionalities required on API invocation process
*
* Convert the response to valid apex wrapper structure
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class APIUtils {
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Construct String by replacing salesforce keywords to the wrapper variable
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    data   			 Response received from API
    * @param    mapreplacement   Map of Salesforce keyword and replacement text
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String mogrifyJSON(String data, Map<String,String> mapreplacement) {
        // Regex to match the start of the line and the key
        // surrounded by quotes and ending with a colon
        String regexFormat = '(?m)^\\s*"{0}"\\s*:';
    
        // Replacement format of the new key surrounded by
        // quotes and ending with a colon
        String replacementFormat = '"{0}" :';
    
        // A map of existing key to replacement key
        Map<String, String> replacements = mapreplacement;
    
        // Since our JSON can come in formatted however the
        // endpoint wants, we need to format it to a standard
        // we know and can handle
        String formattedJSON = JSON.serializePretty(JSON.deserializeUntyped(data));
    
        // Iterate over all the keys we want to replace
        for (String key : replacements.keySet()) {
            system.debug('key---->'+key);
            // Generate our regex based on the key
            String regex = String.format(
                regexFormat,
                new List<String> {key}
            );
    
            // Generate our replacement
            String replacement = String.format(
                replacementFormat,
                new List<String> {replacements.get(key)}
            );
    
            // Find all and replace
            formattedJSON = formattedJSON.replaceAll(regex, replacement);
        }
    
        return formattedJSON;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Query GoogleIdentity__mdt and return to dunamically set endpoint
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Null
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */public static GoogleIdentity__mdt getAPIBaseInfo(){
        GoogleIdentity__mdt googleApp = [Select Id, DeveloperName, AccessTokenURL__c, ClientId__c, ClientSecret__c from GoogleIdentity__mdt where 
        DeveloperName = 'GoogleAuthProvider'];
        return googleApp;
    }
}
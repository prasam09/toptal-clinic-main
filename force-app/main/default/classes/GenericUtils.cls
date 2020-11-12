/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* All Appointment Trigger Logic will be handled in this apex
*
* When an appointment is created,google event post method is invoked async to create an event in 
  Physician's calendar
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class GenericUtils {
    //Record types cache
    private static Map<Schema.SObjectType, Map<String, Schema.RecordTypeInfo>> sObjectToRTMap;
    static {
        sObjectToRTMap = new Map<Schema.SObjectType, Map<String, Schema.RecordTypeInfo>>();
    }


    public static RecordTypeInfo getRTInfoByRTDevName(Schema.SObjectType sObjectType, String rtDevName) {
        if(sObjectType <> null && rtDevName <> null)
        	return getRecordTypeMap(sObjectType).get(rtDevName);
        else
            return null;
    }

    public static String getRTIdByRTDevName(Schema.SObjectType sObjectType, String rtDevName) {
        if(sObjectType <> null && rtDevName <> null){
            RecordTypeInfo recordTypeInfo = getRTInfoByRTDevName(sObjectType, rtDevName);
             if(recordTypeInfo <> null)
                 return recordTypeInfo.getRecordTypeId();
        }
            return null;
    }


    private static Map<String, Schema.RecordTypeInfo> getRecordTypeMap(Schema.SObjectType sObjectType) {
        Map<String, Schema.RecordTypeInfo> rtMap = sObjectToRTMap.get(sObjectType);
        if (rtMap == null) {
            rtMap = sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
            sObjectToRTMap.put(sObjectType, rtMap);
        }
        return rtMap;
    }
}
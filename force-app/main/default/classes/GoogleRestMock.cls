/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Generic Mock Generator class
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
global class GoogleRestMock implements HttpCalloutMock {
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<string , String> responseHeaders;

    public GoogleRestMock(Integer code, String status, String body, Map<String,String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
    
}
@isTest 
global with sharing class UserProfileUpdaterMock implements HTTPCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/JSON');
        res.setBody('Sample Body');
        res.setStatusCode(201);
        return res;
    }
}
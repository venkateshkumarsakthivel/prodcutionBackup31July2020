public with sharing class OTNode {
    public String name {get; set;}
    public Integer id {get;set;}
    public Boolean container {get;set;}
    public String mimetype {get;set;}
    public Integer size {get;set;}
    public String attachmentId {get;set;}
    
    public OTNode(String name, Integer id, Boolean container, String mimetype, Integer size)  {
        this.name = name;
        this.id = id;
        this.container = container;
        this.mimetype = mimetype;
        this.size = size;
    }
    
    /** Used to view and delete attachments on Portal */
    public OTNode(String name, Integer id, Boolean container, String mimetype, Integer size, String attachmentId) {
        this.name = name;
        this.id = id;
        this.container = container;
        this.mimetype = mimetype;
        this.size = size;
        this.attachmentId = attachmentId;
    }
}
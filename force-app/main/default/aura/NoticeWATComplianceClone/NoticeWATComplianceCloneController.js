({
    init : function (component,event, helper) {
        helper.getNoticeRec(component,event);
    },
    
    handleClick : function (component, event, helper) {
		helper.handleClickHandler(component, event);
    },
    
    handleStatusChange : function (component, event, helper) {
        helper.handleStatusChangeHandler(component, event);
    },
    
    navigateToRecord : function (component, event, helper) {
        helper.navigateToRecordHandler(component, event);
    }
})
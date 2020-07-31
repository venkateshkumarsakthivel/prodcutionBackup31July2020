({
	renderManageProfile : function(component) {
        console.log('In renderotherfile 1');
        var action = component.get("c.renderOtherTiles");
        var self = this;
        action.setCallback(this,function(result){
            component.set('v.renderManageProfile',result.getReturnValue());
            console.log('In renderotherfile 1');
            self.renderDVD(component);
        });
        $A.enqueueAction(action);
	},
    renderDVD : function(component) {
        var action = component.get("c.renderDVD");
        var self = this;
        action.setCallback(this,function(result){
            console.log('dvd result: ' + result.getReturnValue());
            component.set('v.renderDVD',result.getReturnValue());
            console.log('In renderDVD 1');
            self.renderLevyAndPayments(component);
        });
        $A.enqueueAction(action);
	},
    renderLevyAndPayments : function(component) {
        var action = component.get("c.renderOtherTiles");
        var self = this;
        action.setCallback(this,function(result){
            console.log(result.getReturnValue());
            component.set('v.renderLevys',result.getReturnValue());
             console.log('In renderotherfile 2');
           
        });
        $A.enqueueAction(action);
	},
    renderRequestDetails : function(component) {
        var action = component.get("c.renderOtherTiles");
        action.setCallback(this,function(result){
            component.set('v.renderedRequestDetail',result.getReturnValue());
            console.log('In renderotherfile 3');
           
        });
        $A.enqueueAction(action);
	},
   
})
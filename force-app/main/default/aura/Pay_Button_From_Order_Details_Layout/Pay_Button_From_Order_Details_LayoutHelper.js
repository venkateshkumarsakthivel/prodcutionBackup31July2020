({
	show : function(component, event) {
        console.log('Async call to fetch order details');
		var _action = component.get("c.show");
        _action.setParams({"Id": component.get("v.recordId")});
        _action.setCallback(this, function(_response) {
            var _state = _response.getState();
            if(_state === "SUCCESS") {
                console.log(JSON.parse(_response.getReturnValue()));
                component.set("v.order", JSON.parse(_response.getReturnValue()));
            }
        });
        
        $A.enqueueAction(_action);
	}
})
({
    handleNavigate: function(component, event) {
        var navigate = component.get("v.navigateFlow");
        navigate(event.getParam("action"));
    },
       
})
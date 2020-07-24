var Action = function() {}

Action.prototype = {
run: function(parameters) {
    parameters.completionFunction({ "URL": document.URL, "title": document.title })
},
    
finalize: function(parameters) {
    let customJS = parameters["customJavaScript"]
    eval(customJS)
}
    
}

var ExtensionPreprocessingJS = new Action

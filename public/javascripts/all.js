var Prototype={Version:'1.5.0',BrowserFeatures:{XPath:!!document.evaluate},ScriptFragment:'(?:<script.*?>)((\n|\r|.)*?)(?:<\/script>)',emptyFunction:function(){},K:function(x){return x}};var Class={create:function(){return function(){this.initialize.apply(this,arguments)}}};var Abstract=new Object();Object.extend=function(destination,source){for(var property in source){destination[property]=source[property]}return destination};Object.extend(Object,{inspect:function(object){try{if(object===undefined)return'undefined';if(object===null)return'null';return object.inspect?object.inspect():object.toString()}catch(e){if(e instanceof RangeError)return'...';throw e;}},keys:function(object){var keys=[];for(var property in object)keys.push(property);return keys},values:function(object){var values=[];for(var property in object)values.push(object[property]);return values},clone:function(object){return Object.extend({},object)}});Function.prototype.bind=function(){var __method=this,args=$A(arguments),object=args.shift();return function(){return __method.apply(object,args.concat($A(arguments)))}};Function.prototype.bindAsEventListener=function(object){var __method=this,args=$A(arguments),object=args.shift();return function(event){return __method.apply(object,[(event||window.event)].concat(args).concat($A(arguments)))}};Object.extend(Number.prototype,{toColorPart:function(){var digits=this.toString(16);if(this<16)return'0'+digits;return digits},succ:function(){return this+1},times:function(iterator){$R(0,this,true).each(iterator);return this}});var Try={these:function(){var returnValue;for(var i=0,length=arguments.length;i<length;i++){var lambda=arguments[i];try{returnValue=lambda();break}catch(e){}}return returnValue}};var PeriodicalExecuter=Class.create();PeriodicalExecuter.prototype={initialize:function(callback,frequency){this.callback=callback;this.frequency=frequency;this.currentlyExecuting=false;this.registerCallback()},registerCallback:function(){this.timer=setInterval(this.onTimerEvent.bind(this),this.frequency*1000)},stop:function(){if(!this.timer)return;clearInterval(this.timer);this.timer=null},onTimerEvent:function(){if(!this.currentlyExecuting){try{this.currentlyExecuting=true;this.callback(this)}finally{this.currentlyExecuting=false}}}};String.interpret=function(value){return value==null?'':String(value)};Object.extend(String.prototype,{gsub:function(pattern,replacement){var result='',source=this,match;replacement=arguments.callee.prepareReplacement(replacement);while(source.length>0){if(match=source.match(pattern)){result+=source.slice(0,match.index);result+=String.interpret(replacement(match));source=source.slice(match.index+match[0].length)}else{result+=source,source=''}}return result},sub:function(pattern,replacement,count){replacement=this.gsub.prepareReplacement(replacement);count=count===undefined?1:count;return this.gsub(pattern,function(match){if(--count<0)return match[0];return replacement(match)})},scan:function(pattern,iterator){this.gsub(pattern,iterator);return this},truncate:function(length,truncation){length=length||30;truncation=truncation===undefined?'...':truncation;return this.length>length?this.slice(0,length-truncation.length)+truncation:this},strip:function(){return this.replace(/^\s+/,'').replace(/\s+$/,'')},stripTags:function(){return this.replace(/<\/?[^>]+>/gi,'')},stripScripts:function(){return this.replace(new RegExp(Prototype.ScriptFragment,'img'),'')},extractScripts:function(){var matchAll=new RegExp(Prototype.ScriptFragment,'img');var matchOne=new RegExp(Prototype.ScriptFragment,'im');return(this.match(matchAll)||[]).map(function(scriptTag){return(scriptTag.match(matchOne)||['',''])[1]})},evalScripts:function(){return this.extractScripts().map(function(script){return eval(script)})},escapeHTML:function(){var div=document.createElement('div');var text=document.createTextNode(this);div.appendChild(text);return div.innerHTML},unescapeHTML:function(){var div=document.createElement('div');div.innerHTML=this.stripTags();return div.childNodes[0]?(div.childNodes.length>1?$A(div.childNodes).inject('',function(memo,node){return memo+node.nodeValue}):div.childNodes[0].nodeValue):''},toQueryParams:function(separator){var match=this.strip().match(/([^?#]*)(#.*)?$/);if(!match)return{};return match[1].split(separator||'&').inject({},function(hash,pair){if((pair=pair.split('='))[0]){var name=decodeURIComponent(pair[0]);var value=pair[1]?decodeURIComponent(pair[1]):undefined;if(hash[name]!==undefined){if(hash[name].constructor!=Array)hash[name]=[hash[name]];if(value)hash[name].push(value)}else hash[name]=value}return hash})},toArray:function(){return this.split('')},succ:function(){return this.slice(0,this.length-1)+String.fromCharCode(this.charCodeAt(this.length-1)+1)},camelize:function(){var parts=this.split('-'),len=parts.length;if(len==1)return parts[0];var camelized=this.charAt(0)=='-'?parts[0].charAt(0).toUpperCase()+parts[0].substring(1):parts[0];for(var i=1;i<len;i++)camelized+=parts[i].charAt(0).toUpperCase()+parts[i].substring(1);return camelized},capitalize:function(){return this.charAt(0).toUpperCase()+this.substring(1).toLowerCase()},underscore:function(){return this.gsub(/::/,'/').gsub(/([A-Z]+)([A-Z][a-z])/,'#{1}_#{2}').gsub(/([a-z\d])([A-Z])/,'#{1}_#{2}').gsub(/-/,'_').toLowerCase()},dasherize:function(){return this.gsub(/_/,'-')},inspect:function(useDoubleQuotes){var escapedString=this.replace(/\\/g,'\\\\');if(useDoubleQuotes)return'"'+escapedString.replace(/"/g,'\\"')+'"';else return"'"+escapedString.replace(/'/g,'\\\'')+"'"}});String.prototype.gsub.prepareReplacement=function(replacement){if(typeof replacement=='function')return replacement;var template=new Template(replacement);return function(match){return template.evaluate(match)}};String.prototype.parseQuery=String.prototype.toQueryParams;var Template=Class.create();Template.Pattern=/(^|.|\r|\n)(#\{(.*?)\})/;Template.prototype={initialize:function(template,pattern){this.template=template.toString();this.pattern=pattern||Template.Pattern},evaluate:function(object){return this.template.gsub(this.pattern,function(match){var before=match[1];if(before=='\\')return match[2];return before+String.interpret(object[match[3]])})}};var $break=new Object();var $continue=new Object();var Enumerable={each:function(iterator){var index=0;try{this._each(function(value){try{iterator(value,index++)}catch(e){if(e!=$continue)throw e;}})}catch(e){if(e!=$break)throw e;}return this},eachSlice:function(number,iterator){var index=-number,slices=[],array=this.toArray();while((index+=number)<array.length)slices.push(array.slice(index,index+number));return slices.map(iterator)},all:function(iterator){var result=true;this.each(function(value,index){result=result&&!!(iterator||Prototype.K)(value,index);if(!result)throw $break;});return result},any:function(iterator){var result=false;this.each(function(value,index){if(result=!!(iterator||Prototype.K)(value,index))throw $break;});return result},collect:function(iterator){var results=[];this.each(function(value,index){results.push((iterator||Prototype.K)(value,index))});return results},detect:function(iterator){var result;this.each(function(value,index){if(iterator(value,index)){result=value;throw $break;}});return result},findAll:function(iterator){var results=[];this.each(function(value,index){if(iterator(value,index))results.push(value)});return results},grep:function(pattern,iterator){var results=[];this.each(function(value,index){var stringValue=value.toString();if(stringValue.match(pattern))results.push((iterator||Prototype.K)(value,index))});return results},include:function(object){var found=false;this.each(function(value){if(value==object){found=true;throw $break;}});return found},inGroupsOf:function(number,fillWith){fillWith=fillWith===undefined?null:fillWith;return this.eachSlice(number,function(slice){while(slice.length<number)slice.push(fillWith);return slice})},inject:function(memo,iterator){this.each(function(value,index){memo=iterator(memo,value,index)});return memo},invoke:function(method){var args=$A(arguments).slice(1);return this.map(function(value){return value[method].apply(value,args)})},max:function(iterator){var result;this.each(function(value,index){value=(iterator||Prototype.K)(value,index);if(result==undefined||value>=result)result=value});return result},min:function(iterator){var result;this.each(function(value,index){value=(iterator||Prototype.K)(value,index);if(result==undefined||value<result)result=value});return result},partition:function(iterator){var trues=[],falses=[];this.each(function(value,index){((iterator||Prototype.K)(value,index)?trues:falses).push(value)});return[trues,falses]},pluck:function(property){var results=[];this.each(function(value,index){results.push(value[property])});return results},reject:function(iterator){var results=[];this.each(function(value,index){if(!iterator(value,index))results.push(value)});return results},sortBy:function(iterator){return this.map(function(value,index){return{value:value,criteria:iterator(value,index)}}).sort(function(left,right){var a=left.criteria,b=right.criteria;return a<b?-1:a>b?1:0}).pluck('value')},toArray:function(){return this.map()},zip:function(){var iterator=Prototype.K,args=$A(arguments);if(typeof args.last()=='function')iterator=args.pop();var collections=[this].concat(args).map($A);return this.map(function(value,index){return iterator(collections.pluck(index))})},size:function(){return this.toArray().length},inspect:function(){return'#<Enumerable:'+this.toArray().inspect()+'>'}};Object.extend(Enumerable,{map:Enumerable.collect,find:Enumerable.detect,select:Enumerable.findAll,member:Enumerable.include,entries:Enumerable.toArray});var $A=Array.from=function(iterable){if(!iterable)return[];if(iterable.toArray){return iterable.toArray()}else{var results=[];for(var i=0,length=iterable.length;i<length;i++)results.push(iterable[i]);return results}};Object.extend(Array.prototype,Enumerable);if(!Array.prototype._reverse)Array.prototype._reverse=Array.prototype.reverse;Object.extend(Array.prototype,{_each:function(iterator){for(var i=0,length=this.length;i<length;i++)iterator(this[i])},clear:function(){this.length=0;return this},first:function(){return this[0]},last:function(){return this[this.length-1]},compact:function(){return this.select(function(value){return value!=null})},flatten:function(){return this.inject([],function(array,value){return array.concat(value&&value.constructor==Array?value.flatten():[value])})},without:function(){var values=$A(arguments);return this.select(function(value){return!values.include(value)})},indexOf:function(object){for(var i=0,length=this.length;i<length;i++)if(this[i]==object)return i;return-1},reverse:function(inline){return(inline!==false?this:this.toArray())._reverse()},reduce:function(){return this.length>1?this:this[0]},uniq:function(){return this.inject([],function(array,value){return array.include(value)?array:array.concat([value])})},clone:function(){return[].concat(this)},size:function(){return this.length},inspect:function(){return'['+this.map(Object.inspect).join(', ')+']'}});Array.prototype.toArray=Array.prototype.clone;function $w(string){string=string.strip();return string?string.split(/\s+/):[]}if(window.opera){Array.prototype.concat=function(){var array=[];for(var i=0,length=this.length;i<length;i++)array.push(this[i]);for(var i=0,length=arguments.length;i<length;i++){if(arguments[i].constructor==Array){for(var j=0,arrayLength=arguments[i].length;j<arrayLength;j++)array.push(arguments[i][j])}else{array.push(arguments[i])}}return array}}var Hash=function(obj){Object.extend(this,obj||{})};Object.extend(Hash,{toQueryString:function(obj){var parts=[];this.prototype._each.call(obj,function(pair){if(!pair.key)return;if(pair.value&&pair.value.constructor==Array){var values=pair.value.compact();if(values.length<2)pair.value=values.reduce();else{key=encodeURIComponent(pair.key);values.each(function(value){value=value!=undefined?encodeURIComponent(value):'';parts.push(key+'='+encodeURIComponent(value))});return}}if(pair.value==undefined)pair[1]='';parts.push(pair.map(encodeURIComponent).join('='))});return parts.join('&')}});Object.extend(Hash.prototype,Enumerable);Object.extend(Hash.prototype,{_each:function(iterator){for(var key in this){var value=this[key];if(value&&value==Hash.prototype[key])continue;var pair=[key,value];pair.key=key;pair.value=value;iterator(pair)}},keys:function(){return this.pluck('key')},values:function(){return this.pluck('value')},merge:function(hash){return $H(hash).inject(this,function(mergedHash,pair){mergedHash[pair.key]=pair.value;return mergedHash})},remove:function(){var result;for(var i=0,length=arguments.length;i<length;i++){var value=this[arguments[i]];if(value!==undefined){if(result===undefined)result=value;else{if(result.constructor!=Array)result=[result];result.push(value)}}delete this[arguments[i]]}return result},toQueryString:function(){return Hash.toQueryString(this)},inspect:function(){return'#<Hash:{'+this.map(function(pair){return pair.map(Object.inspect).join(': ')}).join(', ')+'}>'}});function $H(object){if(object&&object.constructor==Hash)return object;return new Hash(object)};ObjectRange=Class.create();Object.extend(ObjectRange.prototype,Enumerable);Object.extend(ObjectRange.prototype,{initialize:function(start,end,exclusive){this.start=start;this.end=end;this.exclusive=exclusive},_each:function(iterator){var value=this.start;while(this.include(value)){iterator(value);value=value.succ()}},include:function(value){if(value<this.start)return false;if(this.exclusive)return value<this.end;return value<=this.end}});var $R=function(start,end,exclusive){return new ObjectRange(start,end,exclusive)};var Ajax={getTransport:function(){return Try.these(function(){return new XMLHttpRequest()},function(){return new ActiveXObject('Msxml2.XMLHTTP')},function(){return new ActiveXObject('Microsoft.XMLHTTP')})||false},activeRequestCount:0};Ajax.Responders={responders:[],_each:function(iterator){this.responders._each(iterator)},register:function(responder){if(!this.include(responder))this.responders.push(responder)},unregister:function(responder){this.responders=this.responders.without(responder)},dispatch:function(callback,request,transport,json){this.each(function(responder){if(typeof responder[callback]=='function'){try{responder[callback].apply(responder,[request,transport,json])}catch(e){}}})}};Object.extend(Ajax.Responders,Enumerable);Ajax.Responders.register({onCreate:function(){Ajax.activeRequestCount++},onComplete:function(){Ajax.activeRequestCount--}});Ajax.Base=function(){};Ajax.Base.prototype={setOptions:function(options){this.options={method:'post',asynchronous:true,contentType:'application/x-www-form-urlencoded',encoding:'UTF-8',parameters:''};Object.extend(this.options,options||{});this.options.method=this.options.method.toLowerCase();if(typeof this.options.parameters=='string')this.options.parameters=this.options.parameters.toQueryParams()}};Ajax.Request=Class.create();Ajax.Request.Events=['Uninitialized','Loading','Loaded','Interactive','Complete'];Ajax.Request.prototype=Object.extend(new Ajax.Base(),{_complete:false,initialize:function(url,options){this.transport=Ajax.getTransport();this.setOptions(options);this.request(url)},request:function(url){this.url=url;this.method=this.options.method;var params=this.options.parameters;if(!['get','post'].include(this.method)){params['_method']=this.method;this.method='post'}params=Hash.toQueryString(params);if(params&&/Konqueror|Safari|KHTML/.test(navigator.userAgent))params+='&_=';if(this.method=='get'&&params)this.url+=(this.url.indexOf('?')>-1?'&':'?')+params;try{Ajax.Responders.dispatch('onCreate',this,this.transport);this.transport.open(this.method.toUpperCase(),this.url,this.options.asynchronous);if(this.options.asynchronous)setTimeout(function(){this.respondToReadyState(1)}.bind(this),10);this.transport.onreadystatechange=this.onStateChange.bind(this);this.setRequestHeaders();var body=this.method=='post'?(this.options.postBody||params):null;this.transport.send(body);if(!this.options.asynchronous&&this.transport.overrideMimeType)this.onStateChange()}catch(e){this.dispatchException(e)}},onStateChange:function(){var readyState=this.transport.readyState;if(readyState>1&&!((readyState==4)&&this._complete))this.respondToReadyState(this.transport.readyState)},setRequestHeaders:function(){var headers={'X-Requested-With':'XMLHttpRequest','X-Prototype-Version':Prototype.Version,'Accept':'text/javascript, text/html, application/xml, text/xml, */*'};if(this.method=='post'){headers['Content-type']=this.options.contentType+(this.options.encoding?'; charset='+this.options.encoding:'');if(this.transport.overrideMimeType&&(navigator.userAgent.match(/Gecko\/(\d{4})/)||[0,2005])[1]<2005)headers['Connection']='close'}if(typeof this.options.requestHeaders=='object'){var extras=this.options.requestHeaders;if(typeof extras.push=='function')for(var i=0,length=extras.length;i<length;i+=2)headers[extras[i]]=extras[i+1];else $H(extras).each(function(pair){headers[pair.key]=pair.value})}for(var name in headers)this.transport.setRequestHeader(name,headers[name])},success:function(){return!this.transport.status||(this.transport.status>=200&&this.transport.status<300)},respondToReadyState:function(readyState){var state=Ajax.Request.Events[readyState];var transport=this.transport,json=this.evalJSON();if(state=='Complete'){try{this._complete=true;(this.options['on'+this.transport.status]||this.options['on'+(this.success()?'Success':'Failure')]||Prototype.emptyFunction)(transport,json)}catch(e){this.dispatchException(e)}if((this.getHeader('Content-type')||'text/javascript').strip().match(/^(text|application)\/(x-)?(java|ecma)script(;.*)?$/i))this.evalResponse()}try{(this.options['on'+state]||Prototype.emptyFunction)(transport,json);Ajax.Responders.dispatch('on'+state,this,transport,json)}catch(e){this.dispatchException(e)}if(state=='Complete'){this.transport.onreadystatechange=Prototype.emptyFunction}},getHeader:function(name){try{return this.transport.getResponseHeader(name)}catch(e){return null}},evalJSON:function(){try{var json=this.getHeader('X-JSON');return json?eval('('+json+')'):null}catch(e){return null}},evalResponse:function(){try{return eval(this.transport.responseText)}catch(e){this.dispatchException(e)}},dispatchException:function(exception){(this.options.onException||Prototype.emptyFunction)(this,exception);Ajax.Responders.dispatch('onException',this,exception)}});Ajax.Updater=Class.create();Object.extend(Object.extend(Ajax.Updater.prototype,Ajax.Request.prototype),{initialize:function(container,url,options){this.container={success:(container.success||container),failure:(container.failure||(container.success?null:container))};this.transport=Ajax.getTransport();this.setOptions(options);var onComplete=this.options.onComplete||Prototype.emptyFunction;this.options.onComplete=(function(transport,param){this.updateContent();onComplete(transport,param)}).bind(this);this.request(url)},updateContent:function(){var receiver=this.container[this.success()?'success':'failure'];var response=this.transport.responseText;if(!this.options.evalScripts)response=response.stripScripts();if(receiver=$(receiver)){if(this.options.insertion)new this.options.insertion(receiver,response);else receiver.update(response)}if(this.success()){if(this.onComplete)setTimeout(this.onComplete.bind(this),10)}}});Ajax.PeriodicalUpdater=Class.create();Ajax.PeriodicalUpdater.prototype=Object.extend(new Ajax.Base(),{initialize:function(container,url,options){this.setOptions(options);this.onComplete=this.options.onComplete;this.frequency=(this.options.frequency||2);this.decay=(this.options.decay||1);this.updater={};this.container=container;this.url=url;this.start()},start:function(){this.options.onComplete=this.updateComplete.bind(this);this.onTimerEvent()},stop:function(){this.updater.options.onComplete=undefined;clearTimeout(this.timer);(this.onComplete||Prototype.emptyFunction).apply(this,arguments)},updateComplete:function(request){if(this.options.decay){this.decay=(request.responseText==this.lastText?this.decay*this.options.decay:1);this.lastText=request.responseText}this.timer=setTimeout(this.onTimerEvent.bind(this),this.decay*this.frequency*1000)},onTimerEvent:function(){this.updater=new Ajax.Updater(this.container,this.url,this.options)}});function $(element){if(arguments.length>1){for(var i=0,elements=[],length=arguments.length;i<length;i++)elements.push($(arguments[i]));return elements}if(typeof element=='string')element=document.getElementById(element);return Element.extend(element)}if(Prototype.BrowserFeatures.XPath){document._getElementsByXPath=function(expression,parentElement){var results=[];var query=document.evaluate(expression,$(parentElement)||document,null,XPathResult.ORDERED_NODE_SNAPSHOT_TYPE,null);for(var i=0,length=query.snapshotLength;i<length;i++)results.push(query.snapshotItem(i));return results}}document.getElementsByClassName=function(className,parentElement){if(Prototype.BrowserFeatures.XPath){var q=".//*[contains(concat(' ', @class, ' '), ' "+className+" ')]";return document._getElementsByXPath(q,parentElement)}else{var children=($(parentElement)||document.body).getElementsByTagName('*');var elements=[],child;for(var i=0,length=children.length;i<length;i++){child=children[i];if(Element.hasClassName(child,className))elements.push(Element.extend(child))}return elements}};if(!window.Element)var Element=new Object();Element.extend=function(element){if(!element||_nativeExtensions||element.nodeType==3)return element;if(!element._extended&&element.tagName&&element!=window){var methods=Object.clone(Element.Methods),cache=Element.extend.cache;if(element.tagName=='FORM')Object.extend(methods,Form.Methods);if(['INPUT','TEXTAREA','SELECT'].include(element.tagName))Object.extend(methods,Form.Element.Methods);Object.extend(methods,Element.Methods.Simulated);for(var property in methods){var value=methods[property];if(typeof value=='function'&&!(property in element))element[property]=cache.findOrStore(value)}}element._extended=true;return element};Element.extend.cache={findOrStore:function(value){return this[value]=this[value]||function(){return value.apply(null,[this].concat($A(arguments)))}}};Element.Methods={visible:function(element){return $(element).style.display!='none'},toggle:function(element){element=$(element);Element[Element.visible(element)?'hide':'show'](element);return element},hide:function(element){$(element).style.display='none';return element},show:function(element){$(element).style.display='';return element},remove:function(element){element=$(element);element.parentNode.removeChild(element);return element},update:function(element,html){html=typeof html=='undefined'?'':html.toString();$(element).innerHTML=html.stripScripts();setTimeout(function(){html.evalScripts()},10);return element},replace:function(element,html){element=$(element);html=typeof html=='undefined'?'':html.toString();if(element.outerHTML){element.outerHTML=html.stripScripts()}else{var range=element.ownerDocument.createRange();range.selectNodeContents(element);element.parentNode.replaceChild(range.createContextualFragment(html.stripScripts()),element)}setTimeout(function(){html.evalScripts()},10);return element},inspect:function(element){element=$(element);var result='<'+element.tagName.toLowerCase();$H({'id':'id','className':'class'}).each(function(pair){var property=pair.first(),attribute=pair.last();var value=(element[property]||'').toString();if(value)result+=' '+attribute+'='+value.inspect(true)});return result+'>'},recursivelyCollect:function(element,property){element=$(element);var elements=[];while(element=element[property])if(element.nodeType==1)elements.push(Element.extend(element));return elements},ancestors:function(element){return $(element).recursivelyCollect('parentNode')},descendants:function(element){return $A($(element).getElementsByTagName('*'))},immediateDescendants:function(element){if(!(element=$(element).firstChild))return[];while(element&&element.nodeType!=1)element=element.nextSibling;if(element)return[element].concat($(element).nextSiblings());return[]},previousSiblings:function(element){return $(element).recursivelyCollect('previousSibling')},nextSiblings:function(element){return $(element).recursivelyCollect('nextSibling')},siblings:function(element){element=$(element);return element.previousSiblings().reverse().concat(element.nextSiblings())},match:function(element,selector){if(typeof selector=='string')selector=new Selector(selector);return selector.match($(element))},up:function(element,expression,index){return Selector.findElement($(element).ancestors(),expression,index)},down:function(element,expression,index){return Selector.findElement($(element).descendants(),expression,index)},previous:function(element,expression,index){return Selector.findElement($(element).previousSiblings(),expression,index)},next:function(element,expression,index){return Selector.findElement($(element).nextSiblings(),expression,index)},getElementsBySelector:function(){var args=$A(arguments),element=$(args.shift());return Selector.findChildElements(element,args)},getElementsByClassName:function(element,className){return document.getElementsByClassName(className,element)},readAttribute:function(element,name){element=$(element);if(document.all&&!window.opera){var t=Element._attributeTranslations;if(t.values[name])return t.values[name](element,name);if(t.names[name])name=t.names[name];var attribute=element.attributes[name];if(attribute)return attribute.nodeValue}return element.getAttribute(name)},getHeight:function(element){return $(element).getDimensions().height},getWidth:function(element){return $(element).getDimensions().width},classNames:function(element){return new Element.ClassNames(element)},hasClassName:function(element,className){if(!(element=$(element)))return;var elementClassName=element.className;if(elementClassName.length==0)return false;if(elementClassName==className||elementClassName.match(new RegExp("(^|\\s)"+className+"(\\s|$)")))return true;return false},addClassName:function(element,className){if(!(element=$(element)))return;Element.classNames(element).add(className);return element},removeClassName:function(element,className){if(!(element=$(element)))return;Element.classNames(element).remove(className);return element},toggleClassName:function(element,className){if(!(element=$(element)))return;Element.classNames(element)[element.hasClassName(className)?'remove':'add'](className);return element},observe:function(){Event.observe.apply(Event,arguments);return $A(arguments).first()},stopObserving:function(){Event.stopObserving.apply(Event,arguments);return $A(arguments).first()},cleanWhitespace:function(element){element=$(element);var node=element.firstChild;while(node){var nextNode=node.nextSibling;if(node.nodeType==3&&!/\S/.test(node.nodeValue))element.removeChild(node);node=nextNode}return element},empty:function(element){return $(element).innerHTML.match(/^\s*$/)},descendantOf:function(element,ancestor){element=$(element),ancestor=$(ancestor);while(element=element.parentNode)if(element==ancestor)return true;return false},scrollTo:function(element){element=$(element);var pos=Position.cumulativeOffset(element);window.scrollTo(pos[0],pos[1]);return element},getStyle:function(element,style){element=$(element);if(['float','cssFloat'].include(style))style=(typeof element.style.styleFloat!='undefined'?'styleFloat':'cssFloat');style=style.camelize();var value=element.style[style];if(!value){if(document.defaultView&&document.defaultView.getComputedStyle){var css=document.defaultView.getComputedStyle(element,null);value=css?css[style]:null}else if(element.currentStyle){value=element.currentStyle[style]}}if((value=='auto')&&['width','height'].include(style)&&(element.getStyle('display')!='none'))value=element['offset'+style.capitalize()]+'px';if(window.opera&&['left','top','right','bottom'].include(style))if(Element.getStyle(element,'position')=='static')value='auto';if(style=='opacity'){if(value)return parseFloat(value);if(value=(element.getStyle('filter')||'').match(/alpha\(opacity=(.*)\)/))if(value[1])return parseFloat(value[1])/100;return 1.0}return value=='auto'?null:value},setStyle:function(element,style){element=$(element);for(var name in style){var value=style[name];if(name=='opacity'){if(value==1){value=(/Gecko/.test(navigator.userAgent)&&!/Konqueror|Safari|KHTML/.test(navigator.userAgent))?0.999999:1.0;if(/MSIE/.test(navigator.userAgent)&&!window.opera)element.style.filter=element.getStyle('filter').replace(/alpha\([^\)]*\)/gi,'')}else if(value==''){if(/MSIE/.test(navigator.userAgent)&&!window.opera)element.style.filter=element.getStyle('filter').replace(/alpha\([^\)]*\)/gi,'')}else{if(value<0.00001)value=0;if(/MSIE/.test(navigator.userAgent)&&!window.opera)element.style.filter=element.getStyle('filter').replace(/alpha\([^\)]*\)/gi,'')+'alpha(opacity='+value*100+')'}}else if(['float','cssFloat'].include(name))name=(typeof element.style.styleFloat!='undefined')?'styleFloat':'cssFloat';element.style[name.camelize()]=value}return element},getDimensions:function(element){element=$(element);var display=$(element).getStyle('display');if(display!='none'&&display!=null)return{width:element.offsetWidth,height:element.offsetHeight};var els=element.style;var originalVisibility=els.visibility;var originalPosition=els.position;var originalDisplay=els.display;els.visibility='hidden';els.position='absolute';els.display='block';var originalWidth=element.clientWidth;var originalHeight=element.clientHeight;els.display=originalDisplay;els.position=originalPosition;els.visibility=originalVisibility;return{width:originalWidth,height:originalHeight}},makePositioned:function(element){element=$(element);var pos=Element.getStyle(element,'position');if(pos=='static'||!pos){element._madePositioned=true;element.style.position='relative';if(window.opera){element.style.top=0;element.style.left=0}}return element},undoPositioned:function(element){element=$(element);if(element._madePositioned){element._madePositioned=undefined;element.style.position=element.style.top=element.style.left=element.style.bottom=element.style.right=''}return element},makeClipping:function(element){element=$(element);if(element._overflow)return element;element._overflow=element.style.overflow||'auto';if((Element.getStyle(element,'overflow')||'visible')!='hidden')element.style.overflow='hidden';return element},undoClipping:function(element){element=$(element);if(!element._overflow)return element;element.style.overflow=element._overflow=='auto'?'':element._overflow;element._overflow=null;return element}};Object.extend(Element.Methods,{childOf:Element.Methods.descendantOf});Element._attributeTranslations={};Element._attributeTranslations.names={colspan:"colSpan",rowspan:"rowSpan",valign:"vAlign",datetime:"dateTime",accesskey:"accessKey",tabindex:"tabIndex",enctype:"encType",maxlength:"maxLength",readonly:"readOnly",longdesc:"longDesc"};Element._attributeTranslations.values={_getAttr:function(element,attribute){return element.getAttribute(attribute,2)},_flag:function(element,attribute){return $(element).hasAttribute(attribute)?attribute:null},style:function(element){return element.style.cssText.toLowerCase()},title:function(element){var node=element.getAttributeNode('title');return node.specified?node.nodeValue:null}};Object.extend(Element._attributeTranslations.values,{href:Element._attributeTranslations.values._getAttr,src:Element._attributeTranslations.values._getAttr,disabled:Element._attributeTranslations.values._flag,checked:Element._attributeTranslations.values._flag,readonly:Element._attributeTranslations.values._flag,multiple:Element._attributeTranslations.values._flag});Element.Methods.Simulated={hasAttribute:function(element,attribute){var t=Element._attributeTranslations;attribute=t.names[attribute]||attribute;return $(element).getAttributeNode(attribute).specified}};if(document.all&&!window.opera){Element.Methods.update=function(element,html){element=$(element);html=typeof html=='undefined'?'':html.toString();var tagName=element.tagName.toUpperCase();if(['THEAD','TBODY','TR','TD'].include(tagName)){var div=document.createElement('div');switch(tagName){case'THEAD':case'TBODY':div.innerHTML='<table><tbody>'+html.stripScripts()+'</tbody></table>';depth=2;break;case'TR':div.innerHTML='<table><tbody><tr>'+html.stripScripts()+'</tr></tbody></table>';depth=3;break;case'TD':div.innerHTML='<table><tbody><tr><td>'+html.stripScripts()+'</td></tr></tbody></table>';depth=4}$A(element.childNodes).each(function(node){element.removeChild(node)});depth.times(function(){div=div.firstChild});$A(div.childNodes).each(function(node){element.appendChild(node)})}else{element.innerHTML=html.stripScripts()}setTimeout(function(){html.evalScripts()},10);return element}};Object.extend(Element,Element.Methods);var _nativeExtensions=false;if(/Konqueror|Safari|KHTML/.test(navigator.userAgent))['','Form','Input','TextArea','Select'].each(function(tag){var className='HTML'+tag+'Element';if(window[className])return;var klass=window[className]={};klass.prototype=document.createElement(tag?tag.toLowerCase():'div').__proto__});Element.addMethods=function(methods){Object.extend(Element.Methods,methods||{});function copy(methods,destination,onlyIfAbsent){onlyIfAbsent=onlyIfAbsent||false;var cache=Element.extend.cache;for(var property in methods){var value=methods[property];if(!onlyIfAbsent||!(property in destination))destination[property]=cache.findOrStore(value)}}if(typeof HTMLElement!='undefined'){copy(Element.Methods,HTMLElement.prototype);copy(Element.Methods.Simulated,HTMLElement.prototype,true);copy(Form.Methods,HTMLFormElement.prototype);[HTMLInputElement,HTMLTextAreaElement,HTMLSelectElement].each(function(klass){copy(Form.Element.Methods,klass.prototype)});_nativeExtensions=true}};var Toggle=new Object();Toggle.display=Element.toggle;Abstract.Insertion=function(adjacency){this.adjacency=adjacency};Abstract.Insertion.prototype={initialize:function(element,content){this.element=$(element);this.content=content.stripScripts();if(this.adjacency&&this.element.insertAdjacentHTML){try{this.element.insertAdjacentHTML(this.adjacency,this.content)}catch(e){var tagName=this.element.tagName.toUpperCase();if(['TBODY','TR'].include(tagName)){this.insertContent(this.contentFromAnonymousTable())}else{throw e;}}}else{this.range=this.element.ownerDocument.createRange();if(this.initializeRange)this.initializeRange();this.insertContent([this.range.createContextualFragment(this.content)])}setTimeout(function(){content.evalScripts()},10)},contentFromAnonymousTable:function(){var div=document.createElement('div');div.innerHTML='<table><tbody>'+this.content+'</tbody></table>';return $A(div.childNodes[0].childNodes[0].childNodes)}};var Insertion=new Object();Insertion.Before=Class.create();Insertion.Before.prototype=Object.extend(new Abstract.Insertion('beforeBegin'),{initializeRange:function(){this.range.setStartBefore(this.element)},insertContent:function(fragments){fragments.each((function(fragment){this.element.parentNode.insertBefore(fragment,this.element)}).bind(this))}});Insertion.Top=Class.create();Insertion.Top.prototype=Object.extend(new Abstract.Insertion('afterBegin'),{initializeRange:function(){this.range.selectNodeContents(this.element);this.range.collapse(true)},insertContent:function(fragments){fragments.reverse(false).each((function(fragment){this.element.insertBefore(fragment,this.element.firstChild)}).bind(this))}});Insertion.Bottom=Class.create();Insertion.Bottom.prototype=Object.extend(new Abstract.Insertion('beforeEnd'),{initializeRange:function(){this.range.selectNodeContents(this.element);this.range.collapse(this.element)},insertContent:function(fragments){fragments.each((function(fragment){this.element.appendChild(fragment)}).bind(this))}});Insertion.After=Class.create();Insertion.After.prototype=Object.extend(new Abstract.Insertion('afterEnd'),{initializeRange:function(){this.range.setStartAfter(this.element)},insertContent:function(fragments){fragments.each((function(fragment){this.element.parentNode.insertBefore(fragment,this.element.nextSibling)}).bind(this))}});Element.ClassNames=Class.create();Element.ClassNames.prototype={initialize:function(element){this.element=$(element)},_each:function(iterator){this.element.className.split(/\s+/).select(function(name){return name.length>0})._each(iterator)},set:function(className){this.element.className=className},add:function(classNameToAdd){if(this.include(classNameToAdd))return;this.set($A(this).concat(classNameToAdd).join(' '))},remove:function(classNameToRemove){if(!this.include(classNameToRemove))return;this.set($A(this).without(classNameToRemove).join(' '))},toString:function(){return $A(this).join(' ')}};Object.extend(Element.ClassNames.prototype,Enumerable);var Selector=Class.create();Selector.prototype={initialize:function(expression){this.params={classNames:[]};this.expression=expression.toString().strip();this.parseExpression();this.compileMatcher()},parseExpression:function(){function abort(message){throw'Parse error in selector: '+message;}if(this.expression=='')abort('empty expression');var params=this.params,expr=this.expression,match,modifier,clause,rest;while(match=expr.match(/^(.*)\[([a-z0-9_:-]+?)(?:([~\|!]?=)(?:"([^"]*)"|([^\]\s]*)))?\]$/i)){params.attributes=params.attributes||[];params.attributes.push({name:match[2],operator:match[3],value:match[4]||match[5]||''});expr=match[1]}if(expr=='*')return this.params.wildcard=true;while(match=expr.match(/^([^a-z0-9_-])?([a-z0-9_-]+)(.*)/i)){modifier=match[1],clause=match[2],rest=match[3];switch(modifier){case'#':params.id=clause;break;case'.':params.classNames.push(clause);break;case'':case undefined:params.tagName=clause.toUpperCase();break;default:abort(expr.inspect())}expr=rest}if(expr.length>0)abort(expr.inspect())},buildMatchExpression:function(){var params=this.params,conditions=[],clause;if(params.wildcard)conditions.push('true');if(clause=params.id)conditions.push('element.readAttribute("id") == '+clause.inspect());if(clause=params.tagName)conditions.push('element.tagName.toUpperCase() == '+clause.inspect());if((clause=params.classNames).length>0)for(var i=0,length=clause.length;i<length;i++)conditions.push('element.hasClassName('+clause[i].inspect()+')');if(clause=params.attributes){clause.each(function(attribute){var value='element.readAttribute('+attribute.name.inspect()+')';var splitValueBy=function(delimiter){return value+' && '+value+'.split('+delimiter.inspect()+')'};switch(attribute.operator){case'=':conditions.push(value+' == '+attribute.value.inspect());break;case'~=':conditions.push(splitValueBy(' ')+'.include('+attribute.value.inspect()+')');break;case'|=':conditions.push(splitValueBy('-')+'.first().toUpperCase() == '+attribute.value.toUpperCase().inspect());break;case'!=':conditions.push(value+' != '+attribute.value.inspect());break;case'':case undefined:conditions.push('element.hasAttribute('+attribute.name.inspect()+')');break;default:throw'Unknown operator '+attribute.operator+' in selector';}})}return conditions.join(' && ')},compileMatcher:function(){this.match=new Function('element','if(!element.tagName){ return false;} return '+this.buildMatchExpression())},findElements:function(scope){var element;if(element=$(this.params.id))if(this.match(element))if(!scope||Element.childOf(element,scope))return[element];scope=(scope||document).getElementsByTagName(this.params.tagName||'*');var results=[];for(var i=0,length=scope.length;i<length;i++)if(this.match(element=scope[i]))results.push(Element.extend(element));return results},toString:function(){return this.expression}};Object.extend(Selector,{matchElements:function(elements,expression){var selector=new Selector(expression);return elements.select(selector.match.bind(selector)).map(Element.extend)},findElement:function(elements,expression,index){if(typeof expression=='number')index=expression,expression=false;return Selector.matchElements(elements,expression||'*')[index||0]},findChildElements:function(element,expressions){return expressions.map(function(expression){return expression.match(/[^\s"]+(?:"[^"]*"[^\s"]+)*/g).inject([null],function(results,expr){var selector=new Selector(expr);return results.inject([],function(elements,result){return elements.concat(selector.findElements(result||element))})})}).flatten()}});function $$(){return Selector.findChildElements(document,$A(arguments))}var Form={reset:function(form){$(form).reset();return form},serializeElements:function(elements,getHash){var data=elements.inject({},function(result,element){if(!element.disabled&&element.name){var key=element.name,value=$(element).getValue();if(value!=undefined){if(result[key]){if(result[key].constructor!=Array)result[key]=[result[key]];result[key].push(value)}else result[key]=value}}return result});return getHash?data:Hash.toQueryString(data)}};Form.Methods={serialize:function(form,getHash){return Form.serializeElements(Form.getElements(form),getHash)},getElements:function(form){return $A($(form).getElementsByTagName('*')).inject([],function(elements,child){if(Form.Element.Serializers[child.tagName.toLowerCase()])elements.push(Element.extend(child));return elements})},getInputs:function(form,typeName,name){form=$(form);var inputs=form.getElementsByTagName('input');if(!typeName&&!name)return $A(inputs).map(Element.extend);for(var i=0,matchingInputs=[],length=inputs.length;i<length;i++){var input=inputs[i];if((typeName&&input.type!=typeName)||(name&&input.name!=name))continue;matchingInputs.push(Element.extend(input))}return matchingInputs},disable:function(form){form=$(form);form.getElements().each(function(element){element.blur();element.disabled='true'});return form},enable:function(form){form=$(form);form.getElements().each(function(element){element.disabled=''});return form},findFirstElement:function(form){return $(form).getElements().find(function(element){return element.type!='hidden'&&!element.disabled&&['input','select','textarea'].include(element.tagName.toLowerCase())})},focusFirstElement:function(form){form=$(form);form.findFirstElement().activate();return form}};Object.extend(Form,Form.Methods);Form.Element={focus:function(element){$(element).focus();return element},select:function(element){$(element).select();return element}};Form.Element.Methods={serialize:function(element){element=$(element);if(!element.disabled&&element.name){var value=element.getValue();if(value!=undefined){var pair={};pair[element.name]=value;return Hash.toQueryString(pair)}}return''},getValue:function(element){element=$(element);var method=element.tagName.toLowerCase();return Form.Element.Serializers[method](element)},clear:function(element){$(element).value='';return element},present:function(element){return $(element).value!=''},activate:function(element){element=$(element);element.focus();if(element.select&&(element.tagName.toLowerCase()!='input'||!['button','reset','submit'].include(element.type)))element.select();return element},disable:function(element){element=$(element);element.disabled=true;return element},enable:function(element){element=$(element);element.blur();element.disabled=false;return element}};Object.extend(Form.Element,Form.Element.Methods);var Field=Form.Element;var $F=Form.Element.getValue;Form.Element.Serializers={input:function(element){switch(element.type.toLowerCase()){case'checkbox':case'radio':return Form.Element.Serializers.inputSelector(element);default:return Form.Element.Serializers.textarea(element)}},inputSelector:function(element){return element.checked?element.value:null},textarea:function(element){return element.value},select:function(element){return this[element.type=='select-one'?'selectOne':'selectMany'](element)},selectOne:function(element){var index=element.selectedIndex;return index>=0?this.optionValue(element.options[index]):null},selectMany:function(element){var values,length=element.length;if(!length)return null;for(var i=0,values=[];i<length;i++){var opt=element.options[i];if(opt.selected)values.push(this.optionValue(opt))}return values},optionValue:function(opt){return Element.extend(opt).hasAttribute('value')?opt.value:opt.text}};Abstract.TimedObserver=function(){};Abstract.TimedObserver.prototype={initialize:function(element,frequency,callback){this.frequency=frequency;this.element=$(element);this.callback=callback;this.lastValue=this.getValue();this.registerCallback()},registerCallback:function(){setInterval(this.onTimerEvent.bind(this),this.frequency*1000)},onTimerEvent:function(){var value=this.getValue();var changed=('string'==typeof this.lastValue&&'string'==typeof value?this.lastValue!=value:String(this.lastValue)!=String(value));if(changed){this.callback(this.element,value);this.lastValue=value}}};Form.Element.Observer=Class.create();Form.Element.Observer.prototype=Object.extend(new Abstract.TimedObserver(),{getValue:function(){return Form.Element.getValue(this.element)}});Form.Observer=Class.create();Form.Observer.prototype=Object.extend(new Abstract.TimedObserver(),{getValue:function(){return Form.serialize(this.element)}});Abstract.EventObserver=function(){};Abstract.EventObserver.prototype={initialize:function(element,callback){this.element=$(element);this.callback=callback;this.lastValue=this.getValue();if(this.element.tagName.toLowerCase()=='form')this.registerFormCallbacks();else this.registerCallback(this.element)},onElementEvent:function(){var value=this.getValue();if(this.lastValue!=value){this.callback(this.element,value);this.lastValue=value}},registerFormCallbacks:function(){Form.getElements(this.element).each(this.registerCallback.bind(this))},registerCallback:function(element){if(element.type){switch(element.type.toLowerCase()){case'checkbox':case'radio':Event.observe(element,'click',this.onElementEvent.bind(this));break;default:Event.observe(element,'change',this.onElementEvent.bind(this));break}}}};Form.Element.EventObserver=Class.create();Form.Element.EventObserver.prototype=Object.extend(new Abstract.EventObserver(),{getValue:function(){return Form.Element.getValue(this.element)}});Form.EventObserver=Class.create();Form.EventObserver.prototype=Object.extend(new Abstract.EventObserver(),{getValue:function(){return Form.serialize(this.element)}});if(!window.Event){var Event=new Object()}Object.extend(Event,{KEY_BACKSPACE:8,KEY_TAB:9,KEY_RETURN:13,KEY_ESC:27,KEY_LEFT:37,KEY_UP:38,KEY_RIGHT:39,KEY_DOWN:40,KEY_DELETE:46,KEY_HOME:36,KEY_END:35,KEY_PAGEUP:33,KEY_PAGEDOWN:34,element:function(event){return event.target||event.srcElement},isLeftClick:function(event){return(((event.which)&&(event.which==1))||((event.button)&&(event.button==1)))},pointerX:function(event){return event.pageX||(event.clientX+(document.documentElement.scrollLeft||document.body.scrollLeft))},pointerY:function(event){return event.pageY||(event.clientY+(document.documentElement.scrollTop||document.body.scrollTop))},stop:function(event){if(event.preventDefault){event.preventDefault();event.stopPropagation()}else{event.returnValue=false;event.cancelBubble=true}},findElement:function(event,tagName){var element=Event.element(event);while(element.parentNode&&(!element.tagName||(element.tagName.toUpperCase()!=tagName.toUpperCase())))element=element.parentNode;return element},observers:false,_observeAndCache:function(element,name,observer,useCapture){if(!this.observers)this.observers=[];if(element.addEventListener){this.observers.push([element,name,observer,useCapture]);element.addEventListener(name,observer,useCapture)}else if(element.attachEvent){this.observers.push([element,name,observer,useCapture]);element.attachEvent('on'+name,observer)}},unloadCache:function(){if(!Event.observers)return;for(var i=0,length=Event.observers.length;i<length;i++){Event.stopObserving.apply(this,Event.observers[i]);Event.observers[i][0]=null}Event.observers=false},observe:function(element,name,observer,useCapture){element=$(element);useCapture=useCapture||false;if(name=='keypress'&&(navigator.appVersion.match(/Konqueror|Safari|KHTML/)||element.attachEvent))name='keydown';Event._observeAndCache(element,name,observer,useCapture)},stopObserving:function(element,name,observer,useCapture){element=$(element);useCapture=useCapture||false;if(name=='keypress'&&(navigator.appVersion.match(/Konqueror|Safari|KHTML/)||element.detachEvent))name='keydown';if(element.removeEventListener){element.removeEventListener(name,observer,useCapture)}else if(element.detachEvent){try{element.detachEvent('on'+name,observer)}catch(e){}}}});if(navigator.appVersion.match(/\bMSIE\b/))Event.observe(window,'unload',Event.unloadCache,false);var Position={includeScrollOffsets:false,prepare:function(){this.deltaX=window.pageXOffset||document.documentElement.scrollLeft||document.body.scrollLeft||0;this.deltaY=window.pageYOffset||document.documentElement.scrollTop||document.body.scrollTop||0},realOffset:function(element){var valueT=0,valueL=0;do{valueT+=element.scrollTop||0;valueL+=element.scrollLeft||0;element=element.parentNode}while(element);return[valueL,valueT]},cumulativeOffset:function(element){var valueT=0,valueL=0;do{valueT+=element.offsetTop||0;valueL+=element.offsetLeft||0;element=element.offsetParent}while(element);return[valueL,valueT]},positionedOffset:function(element){var valueT=0,valueL=0;do{valueT+=element.offsetTop||0;valueL+=element.offsetLeft||0;element=element.offsetParent;if(element){if(element.tagName=='BODY')break;var p=Element.getStyle(element,'position');if(p=='relative'||p=='absolute')break}}while(element);return[valueL,valueT]},offsetParent:function(element){if(element.offsetParent)return element.offsetParent;if(element==document.body)return element;while((element=element.parentNode)&&element!=document.body)if(Element.getStyle(element,'position')!='static')return element;return document.body},within:function(element,x,y){if(this.includeScrollOffsets)return this.withinIncludingScrolloffsets(element,x,y);this.xcomp=x;this.ycomp=y;this.offset=this.cumulativeOffset(element);return(y>=this.offset[1]&&y<this.offset[1]+element.offsetHeight&&x>=this.offset[0]&&x<this.offset[0]+element.offsetWidth)},withinIncludingScrolloffsets:function(element,x,y){var offsetcache=this.realOffset(element);this.xcomp=x+offsetcache[0]-this.deltaX;this.ycomp=y+offsetcache[1]-this.deltaY;this.offset=this.cumulativeOffset(element);return(this.ycomp>=this.offset[1]&&this.ycomp<this.offset[1]+element.offsetHeight&&this.xcomp>=this.offset[0]&&this.xcomp<this.offset[0]+element.offsetWidth)},overlap:function(mode,element){if(!mode)return 0;if(mode=='vertical')return((this.offset[1]+element.offsetHeight)-this.ycomp)/element.offsetHeight;if(mode=='horizontal')return((this.offset[0]+element.offsetWidth)-this.xcomp)/element.offsetWidth},page:function(forElement){var valueT=0,valueL=0;var element=forElement;do{valueT+=element.offsetTop||0;valueL+=element.offsetLeft||0;if(element.offsetParent==document.body)if(Element.getStyle(element,'position')=='absolute')break}while(element=element.offsetParent);element=forElement;do{if(!window.opera||element.tagName=='BODY'){valueT-=element.scrollTop||0;valueL-=element.scrollLeft||0}}while(element=element.parentNode);return[valueL,valueT]},clone:function(source,target){var options=Object.extend({setLeft:true,setTop:true,setWidth:true,setHeight:true,offsetTop:0,offsetLeft:0},arguments[2]||{});source=$(source);var p=Position.page(source);target=$(target);var delta=[0,0];var parent=null;if(Element.getStyle(target,'position')=='absolute'){parent=Position.offsetParent(target);delta=Position.page(parent)}if(parent==document.body){delta[0]-=document.body.offsetLeft;delta[1]-=document.body.offsetTop}if(options.setLeft)target.style.left=(p[0]-delta[0]+options.offsetLeft)+'px';if(options.setTop)target.style.top=(p[1]-delta[1]+options.offsetTop)+'px';if(options.setWidth)target.style.width=source.offsetWidth+'px';if(options.setHeight)target.style.height=source.offsetHeight+'px'},absolutize:function(element){element=$(element);if(element.style.position=='absolute')return;Position.prepare();var offsets=Position.positionedOffset(element);var top=offsets[1];var left=offsets[0];var width=element.clientWidth;var height=element.clientHeight;element._originalLeft=left-parseFloat(element.style.left||0);element._originalTop=top-parseFloat(element.style.top||0);element._originalWidth=element.style.width;element._originalHeight=element.style.height;element.style.position='absolute';element.style.top=top+'px';element.style.left=left+'px';element.style.width=width+'px';element.style.height=height+'px'},relativize:function(element){element=$(element);if(element.style.position=='relative')return;Position.prepare();element.style.position='relative';var top=parseFloat(element.style.top||0)-(element._originalTop||0);var left=parseFloat(element.style.left||0)-(element._originalLeft||0);element.style.top=top+'px';element.style.left=left+'px';element.style.height=element._originalHeight;element.style.width=element._originalWidth}};if(/Konqueror|Safari|KHTML/.test(navigator.userAgent)){Position.cumulativeOffset=function(element){var valueT=0,valueL=0;do{valueT+=element.offsetTop||0;valueL+=element.offsetLeft||0;if(element.offsetParent==document.body)if(Element.getStyle(element,'position')=='absolute')break;element=element.offsetParent}while(element);return[valueL,valueT]}}Element.addMethods();// Copyright (c) 2005, 2006 Thomas Fuchs (http://script.aculo.us, http://mir.aculo.us)
// Contributors:
//  Justin Palmer (http://encytemedia.com/)
//  Mark Pilgrim (http://diveintomark.org/)
//  Martin Bialasinki
// 
// script.aculo.us is freely distributable under the terms of an MIT-style license.
// For details, see the script.aculo.us web site:http://script.aculo.us/ 
// converts rgb() and #xxx to #xxxxxx format,  
// returns self (or first argument) if not convertable  
String.prototype.parseColor=function(){  
var color='#';
if(this.slice(0,4)=='rgb('){  
var cols=this.slice(4,this.length-1).split(',');  
var i=0; do{ color+=parseInt(cols[i]).toColorPart()} while (++i<3);  
}else{  
if(this.slice(0,1)=='#'){  
if(this.length==4) for(var i=1;i<4;i++) color+=(this.charAt(i)+this.charAt(i)).toLowerCase();  
if(this.length==7) color=this.toLowerCase();  
}  
}  
return(color.length==7 ? color :(arguments[0] || this));  
}
Element.collectTextNodes=function(element){  
return $A($(element).childNodes).collect( function(node){
return (node.nodeType==3 ? node.nodeValue :
(node.hasChildNodes() ? Element.collectTextNodes(node) :''));
}).flatten().join('');
}
Element.collectTextNodesIgnoreClass=function(element, className){  
return $A($(element).childNodes).collect( function(node){
return (node.nodeType==3 ? node.nodeValue :
((node.hasChildNodes() && !Element.hasClassName(node,className)) ? 
Element.collectTextNodesIgnoreClass(node, className) :''));
}).flatten().join('');
}
Element.setContentZoom=function(element, percent){
element=$(element);  
element.setStyle({fontSize:(percent/100)+'em'});   
if(navigator.appVersion.indexOf('AppleWebKit')>0) window.scrollBy(0,0);
return element;
}
Element.getOpacity=function(element){
element=$(element);
var opacity;
if (opacity=element.getStyle('opacity'))  
return parseFloat(opacity);  
if (opacity=(element.getStyle('filter') || '').match(/alpha\(opacity=(.*)\)/))  
if(opacity[1]) return parseFloat(opacity[1]) / 100;  
return 1.0;  
}
Element.setOpacity=function(element, value){  
element= $(element);  
if (value==1){
element.setStyle({ opacity:
(/Gecko/.test(navigator.userAgent) && !/Konqueror|Safari|KHTML/.test(navigator.userAgent)) ? 
0.999999 :1.0});
if(/MSIE/.test(navigator.userAgent) && !window.opera)  
element.setStyle({filter:Element.getStyle(element,'filter').replace(/alpha\([^\)]*\)/gi,'')});  
}else{  
if(value < 0.00001) value=0;  
element.setStyle({opacity:value});
if(/MSIE/.test(navigator.userAgent) && !window.opera)  
element.setStyle(
{ filter:element.getStyle('filter').replace(/alpha\([^\)]*\)/gi,'') +
'alpha(opacity='+value*100+')'});  
}
return element;
}  
Element.getInlineOpacity=function(element){  
return $(element).style.opacity || '';
}  
Element.forceRerendering=function(element){
try{
element=$(element);
var n=document.createTextNode(' ');
element.appendChild(n);
element.removeChild(n);
} catch(e){}
};
Array.prototype.call=function(){
var args=arguments;
this.each(function(f){ f.apply(this, args)});
}
var Effect={
_elementDoesNotExistError:{
name:'ElementDoesNotExistError',
message:'The specified DOM element does not exist, but is required for this effect to operate'
},
tagifyText:function(element){
if(typeof Builder=='undefined')
throw("Effect.tagifyText requires including script.aculo.us' builder.js library");
var tagifyStyle='position:relative';
if(/MSIE/.test(navigator.userAgent) && !window.opera) tagifyStyle+=';zoom:1';
element=$(element);
$A(element.childNodes).each( function(child){
if(child.nodeType==3){
child.nodeValue.toArray().each( function(character){
element.insertBefore(
Builder.node('span',{style:tagifyStyle},
character==' ' ? String.fromCharCode(160) :character), 
child);
});
Element.remove(child);
}
});
},
multiple:function(element, effect){
var elements;
if(((typeof element=='object') || 
(typeof element=='function')) && 
(element.length))
elements=element;
else
elements=$(element).childNodes;
var options=Object.extend({
speed:0.1,
delay:0.0
}, arguments[2] ||{});
var masterDelay=options.delay;
$A(elements).each( function(element, index){
new effect(element, Object.extend(options,{ delay:index * options.speed+masterDelay}));
});
},
PAIRS:{
'slide':['SlideDown','SlideUp'],
'blind':['BlindDown','BlindUp'],
'appear':['Appear','Fade']
},
toggle:function(element, effect){
element=$(element);
effect=(effect || 'appear').toLowerCase();
var options=Object.extend({
queue:{ position:'end', scope:(element.id || 'global'), limit:1}
}, arguments[2] ||{});
Effect[element.visible() ? 
Effect.PAIRS[effect][1] :Effect.PAIRS[effect][0]](element, options);
}
};
var Effect2=Effect;
Effect.Transitions={
linear:Prototype.K,
sinoidal:function(pos){
return (-Math.cos(pos*Math.PI)/2)+0.5;
},
reverse:function(pos){
return 1-pos;
},
flicker:function(pos){
return ((-Math.cos(pos*Math.PI)/4)+0.75)+Math.random()/4;
},
wobble:function(pos){
return (-Math.cos(pos*Math.PI*(9*pos))/2)+0.5;
},
pulse:function(pos, pulses){ 
pulses=pulses || 5; 
return (
Math.round((pos % (1/pulses)) * pulses)==0 ? 
((pos * pulses * 2) - Math.floor(pos * pulses * 2)) :
1 - ((pos * pulses * 2) - Math.floor(pos * pulses * 2))
);
},
none:function(pos){
return 0;
},
full:function(pos){
return 1;
}
};
Effect.ScopedQueue=Class.create();
Object.extend(Object.extend(Effect.ScopedQueue.prototype, Enumerable),{
initialize:function(){
this.effects =[];
this.interval=null;
},
_each:function(iterator){
this.effects._each(iterator);
},
add:function(effect){
var timestamp=new Date().getTime();
var position=(typeof effect.options.queue=='string') ? 
effect.options.queue :effect.options.queue.position;
switch(position){
case 'front':
this.effects.findAll(function(e){ return e.state=='idle'}).each( function(e){
e.startOn +=effect.finishOn;
e.finishOn+=effect.finishOn;
});
break;
case 'with-last':
timestamp=this.effects.pluck('startOn').max() || timestamp;
break;
case 'end':
timestamp=this.effects.pluck('finishOn').max() || timestamp;
break;
}
effect.startOn +=timestamp;
effect.finishOn+=timestamp;
if(!effect.options.queue.limit || (this.effects.length < effect.options.queue.limit))
this.effects.push(effect);
if(!this.interval) 
this.interval=setInterval(this.loop.bind(this), 40);
},
remove:function(effect){
this.effects=this.effects.reject(function(e){ return e==effect});
if(this.effects.length==0){
clearInterval(this.interval);
this.interval=null;
}
},
loop:function(){
var timePos=new Date().getTime();
this.effects.invoke('loop', timePos);
}
});
Effect.Queues={
instances:$H(),
get:function(queueName){
if(typeof queueName != 'string') return queueName;
if(!this.instances[queueName])
this.instances[queueName]=new Effect.ScopedQueue();
return this.instances[queueName];
}
}
Effect.Queue=Effect.Queues.get('global');
Effect.DefaultOptions={
transition:Effect.Transitions.sinoidal,
duration:1.0,  
fps:25.0,  
sync:false, 
from:0.0,
to:1.0,
delay:0.0,
queue:'parallel'
}
Effect.Base=function(){};
Effect.Base.prototype={
position:null,
start:function(options){
this.options     =Object.extend(Object.extend({},Effect.DefaultOptions), options ||{});
this.currentFrame=0;
this.state       ='idle';
this.startOn     =this.options.delay*1000;
this.finishOn    =this.startOn+(this.options.duration*1000);
this.event('beforeStart');
if(!this.options.sync)
Effect.Queues.get(typeof this.options.queue=='string' ? 
'global' :this.options.queue.scope).add(this);
},
loop:function(timePos){
if(timePos >= this.startOn){
if(timePos >= this.finishOn){
this.render(1.0);
this.cancel();
this.event('beforeFinish');
if(this.finish) this.finish(); 
this.event('afterFinish');
return;  
}
var pos  =(timePos - this.startOn) / (this.finishOn - this.startOn);
var frame=Math.round(pos * this.options.fps * this.options.duration);
if(frame > this.currentFrame){
this.render(pos);
this.currentFrame=frame;
}
}
},
render:function(pos){
if(this.state=='idle'){
this.state='running';
this.event('beforeSetup');
if(this.setup) this.setup();
this.event('afterSetup');
}
if(this.state=='running'){
if(this.options.transition) pos=this.options.transition(pos);
pos *= (this.options.to-this.options.from);
pos+=this.options.from;
this.position=pos;
this.event('beforeUpdate');
if(this.update) this.update(pos);
this.event('afterUpdate');
}
},
cancel:function(){
if(!this.options.sync)
Effect.Queues.get(typeof this.options.queue=='string' ? 
'global' :this.options.queue.scope).remove(this);
this.state='finished';
},
event:function(eventName){
if(this.options[eventName+'Internal']) this.options[eventName+'Internal'](this);
if(this.options[eventName]) this.options[eventName](this);
},
inspect:function(){
return '#<Effect:'+$H(this).inspect()+',options:'+$H(this.options).inspect()+'>';
}
}
Effect.Parallel=Class.create();
Object.extend(Object.extend(Effect.Parallel.prototype, Effect.Base.prototype),{
initialize:function(effects){
this.effects=effects || [];
this.start(arguments[1]);
},
update:function(position){
this.effects.invoke('render', position);
},
finish:function(position){
this.effects.each( function(effect){
effect.render(1.0);
effect.cancel();
effect.event('beforeFinish');
if(effect.finish) effect.finish(position);
effect.event('afterFinish');
});
}
});
Effect.Event=Class.create();
Object.extend(Object.extend(Effect.Event.prototype, Effect.Base.prototype),{
initialize:function(){
var options=Object.extend({
duration:0
}, arguments[0] ||{});
this.start(options);
},
update:Prototype.emptyFunction
});
Effect.Opacity=Class.create();
Object.extend(Object.extend(Effect.Opacity.prototype, Effect.Base.prototype),{
initialize:function(element){
this.element=$(element);
if(!this.element) throw(Effect._elementDoesNotExistError);
if(/MSIE/.test(navigator.userAgent) && !window.opera && (!this.element.currentStyle.hasLayout))
this.element.setStyle({zoom:1});
var options=Object.extend({
from:this.element.getOpacity() || 0.0,
to:1.0
}, arguments[1] ||{});
this.start(options);
},
update:function(position){
this.element.setOpacity(position);
}
});
Effect.Move=Class.create();
Object.extend(Object.extend(Effect.Move.prototype, Effect.Base.prototype),{
initialize:function(element){
this.element=$(element);
if(!this.element) throw(Effect._elementDoesNotExistError);
var options=Object.extend({
x:0,
y:0,
mode:'relative'
}, arguments[1] ||{});
this.start(options);
},
setup:function(){
this.element.makePositioned();
this.originalLeft=parseFloat(this.element.getStyle('left') || '0');
this.originalTop =parseFloat(this.element.getStyle('top')  || '0');
if(this.options.mode=='absolute'){
this.options.x=this.options.x - this.originalLeft;
this.options.y=this.options.y - this.originalTop;
}
},
update:function(position){
this.element.setStyle({
left:Math.round(this.options.x  * position+this.originalLeft)+'px',
top:Math.round(this.options.y  * position+this.originalTop) +'px'
});
}
});
Effect.MoveBy=function(element, toTop, toLeft){
return new Effect.Move(element, 
Object.extend({ x:toLeft, y:toTop}, arguments[3] ||{}));
};
Effect.Scale=Class.create();
Object.extend(Object.extend(Effect.Scale.prototype, Effect.Base.prototype),{
initialize:function(element, percent){
this.element=$(element);
if(!this.element) throw(Effect._elementDoesNotExistError);
var options=Object.extend({
scaleX:true,
scaleY:true,
scaleContent:true,
scaleFromCenter:false,
scaleMode:'box',        
scaleFrom:100.0,
scaleTo:percent
}, arguments[2] ||{});
this.start(options);
},
setup:function(){
this.restoreAfterFinish=this.options.restoreAfterFinish || false;
this.elementPositioning=this.element.getStyle('position');
this.originalStyle={};
['top','left','width','height','fontSize'].each( function(k){
this.originalStyle[k]=this.element.style[k];
}.bind(this));
this.originalTop =this.element.offsetTop;
this.originalLeft=this.element.offsetLeft;
var fontSize=this.element.getStyle('font-size') || '100%';
['em','px','%','pt'].each( function(fontSizeType){
if(fontSize.indexOf(fontSizeType)>0){
this.fontSize    =parseFloat(fontSize);
this.fontSizeType=fontSizeType;
}
}.bind(this));
this.factor=(this.options.scaleTo - this.options.scaleFrom)/100;
this.dims=null;
if(this.options.scaleMode=='box')
this.dims=[this.element.offsetHeight, this.element.offsetWidth];
if(/^content/.test(this.options.scaleMode))
this.dims=[this.element.scrollHeight, this.element.scrollWidth];
if(!this.dims)
this.dims=[this.options.scaleMode.originalHeight,
this.options.scaleMode.originalWidth];
},
update:function(position){
var currentScale=(this.options.scaleFrom/100.0)+(this.factor * position);
if(this.options.scaleContent && this.fontSize)
this.element.setStyle({fontSize:this.fontSize * currentScale+this.fontSizeType});
this.setDimensions(this.dims[0] * currentScale, this.dims[1] * currentScale);
},
finish:function(position){
if(this.restoreAfterFinish) this.element.setStyle(this.originalStyle);
},
setDimensions:function(height, width){
var d={};
if(this.options.scaleX) d.width=Math.round(width)+'px';
if(this.options.scaleY) d.height=Math.round(height)+'px';
if(this.options.scaleFromCenter){
var topd =(height - this.dims[0])/2;
var leftd=(width  - this.dims[1])/2;
if(this.elementPositioning=='absolute'){
if(this.options.scaleY) d.top=this.originalTop-topd+'px';
if(this.options.scaleX) d.left=this.originalLeft-leftd+'px';
}else{
if(this.options.scaleY) d.top=-topd+'px';
if(this.options.scaleX) d.left=-leftd+'px';
}
}
this.element.setStyle(d);
}
});
Effect.Highlight=Class.create();
Object.extend(Object.extend(Effect.Highlight.prototype, Effect.Base.prototype),{
initialize:function(element){
this.element=$(element);
if(!this.element) throw(Effect._elementDoesNotExistError);
var options=Object.extend({ startcolor:'#ffff99'}, arguments[1] ||{});
this.start(options);
},
setup:function(){
if(this.element.getStyle('display')=='none'){ this.cancel(); return;}
this.oldStyle={
backgroundImage:this.element.getStyle('background-image')};
this.element.setStyle({backgroundImage:'none'});
if(!this.options.endcolor)
this.options.endcolor=this.element.getStyle('background-color').parseColor('#ffffff');
if(!this.options.restorecolor)
this.options.restorecolor=this.element.getStyle('background-color');
this._base =$R(0,2).map(function(i){ return parseInt(this.options.startcolor.slice(i*2+1,i*2+3),16)}.bind(this));
this._delta=$R(0,2).map(function(i){ return parseInt(this.options.endcolor.slice(i*2+1,i*2+3),16)-this._base[i]}.bind(this));
},
update:function(position){
this.element.setStyle({backgroundColor:$R(0,2).inject('#',function(m,v,i){
return m+(Math.round(this._base[i]+(this._delta[i]*position)).toColorPart());}.bind(this))});
},
finish:function(){
this.element.setStyle(Object.extend(this.oldStyle,{
backgroundColor:this.options.restorecolor
}));
}
});
Effect.ScrollTo=Class.create();
Object.extend(Object.extend(Effect.ScrollTo.prototype, Effect.Base.prototype),{
initialize:function(element){
this.element=$(element);
this.start(arguments[1] ||{});
},
setup:function(){
Position.prepare();
var offsets=Position.cumulativeOffset(this.element);
if(this.options.offset) offsets[1]+=this.options.offset;
var max=window.innerHeight ? 
window.height - window.innerHeight :
document.body.scrollHeight - 
(document.documentElement.clientHeight ? 
document.documentElement.clientHeight :document.body.clientHeight);
this.scrollStart=Position.deltaY;
this.delta=(offsets[1] > max ? max :offsets[1]) - this.scrollStart;
},
update:function(position){
Position.prepare();
window.scrollTo(Position.deltaX, 
this.scrollStart+(position*this.delta));
}
});
Effect.Fade=function(element){
element=$(element);
var oldOpacity=element.getInlineOpacity();
var options=Object.extend({
from:element.getOpacity() || 1.0,
to:0.0,
afterFinishInternal:function(effect){ 
if(effect.options.to!=0) return;
effect.element.hide().setStyle({opacity:oldOpacity}); 
}}, arguments[1] ||{});
return new Effect.Opacity(element,options);
}
Effect.Appear=function(element){
element=$(element);
var options=Object.extend({
from:(element.getStyle('display')=='none' ? 0.0 :element.getOpacity() || 0.0),
to:1.0,
afterFinishInternal:function(effect){
effect.element.forceRerendering();
},
beforeSetup:function(effect){
effect.element.setOpacity(effect.options.from).show(); 
}}, arguments[1] ||{});
return new Effect.Opacity(element,options);
}
Effect.Puff=function(element){
element=$(element);
var oldStyle={ 
opacity:element.getInlineOpacity(), 
position:element.getStyle('position'),
top:element.style.top,
left:element.style.left,
width:element.style.width,
height:element.style.height
};
return new Effect.Parallel(
[ new Effect.Scale(element, 200, 
{ sync:true, scaleFromCenter:true, scaleContent:true, restoreAfterFinish:true}), 
new Effect.Opacity(element,{ sync:true, to:0.0} ) ], 
Object.extend({ duration:1.0, 
beforeSetupInternal:function(effect){
Position.absolutize(effect.effects[0].element)
},
afterFinishInternal:function(effect){
effect.effects[0].element.hide().setStyle(oldStyle);}
}, arguments[1] ||{})
);
}
Effect.BlindUp=function(element){
element=$(element);
element.makeClipping();
return new Effect.Scale(element, 0,
Object.extend({ scaleContent:false, 
scaleX:false, 
restoreAfterFinish:true,
afterFinishInternal:function(effect){
effect.element.hide().undoClipping();
} 
}, arguments[1] ||{})
);
}
Effect.BlindDown=function(element){
element=$(element);
var elementDimensions=element.getDimensions();
return new Effect.Scale(element, 100, Object.extend({ 
scaleContent:false, 
scaleX:false,
scaleFrom:0,
scaleMode:{originalHeight:elementDimensions.height, originalWidth:elementDimensions.width},
restoreAfterFinish:true,
afterSetup:function(effect){
effect.element.makeClipping().setStyle({height:'0px'}).show(); 
},  
afterFinishInternal:function(effect){
effect.element.undoClipping();
}
}, arguments[1] ||{}));
}
Effect.SwitchOff=function(element){
element=$(element);
var oldOpacity=element.getInlineOpacity();
return new Effect.Appear(element, Object.extend({
duration:0.4,
from:0,
transition:Effect.Transitions.flicker,
afterFinishInternal:function(effect){
new Effect.Scale(effect.element, 1,{ 
duration:0.3, scaleFromCenter:true,
scaleX:false, scaleContent:false, restoreAfterFinish:true,
beforeSetup:function(effect){ 
effect.element.makePositioned().makeClipping();
},
afterFinishInternal:function(effect){
effect.element.hide().undoClipping().undoPositioned().setStyle({opacity:oldOpacity});
}
})
}
}, arguments[1] ||{}));
}
Effect.DropOut=function(element){
element=$(element);
var oldStyle={
top:element.getStyle('top'),
left:element.getStyle('left'),
opacity:element.getInlineOpacity()};
return new Effect.Parallel(
[ new Effect.Move(element,{x:0, y:100, sync:true}), 
new Effect.Opacity(element,{ sync:true, to:0.0}) ],
Object.extend(
{ duration:0.5,
beforeSetup:function(effect){
effect.effects[0].element.makePositioned(); 
},
afterFinishInternal:function(effect){
effect.effects[0].element.hide().undoPositioned().setStyle(oldStyle);
} 
}, arguments[1] ||{}));
}
Effect.Shake=function(element){
element=$(element);
var oldStyle={
top:element.getStyle('top'),
left:element.getStyle('left')};
return new Effect.Move(element, 
{ x:20, y:0, duration:0.05, afterFinishInternal:function(effect){
new Effect.Move(effect.element,
{ x:-40, y:0, duration:0.1,  afterFinishInternal:function(effect){
new Effect.Move(effect.element,
{ x:40, y:0, duration:0.1,  afterFinishInternal:function(effect){
new Effect.Move(effect.element,
{ x:-40, y:0, duration:0.1,  afterFinishInternal:function(effect){
new Effect.Move(effect.element,
{ x:40, y:0, duration:0.1,  afterFinishInternal:function(effect){
new Effect.Move(effect.element,
{ x:-20, y:0, duration:0.05, afterFinishInternal:function(effect){
effect.element.undoPositioned().setStyle(oldStyle);
}})}})}})}})}})}});
}
Effect.SlideDown=function(element){
element=$(element).cleanWhitespace();
var oldInnerBottom=element.down().getStyle('bottom');
var elementDimensions=element.getDimensions();
return new Effect.Scale(element, 100, Object.extend({ 
scaleContent:false, 
scaleX:false, 
scaleFrom:window.opera ? 0 :1,
scaleMode:{originalHeight:elementDimensions.height, originalWidth:elementDimensions.width},
restoreAfterFinish:true,
afterSetup:function(effect){
effect.element.makePositioned();
effect.element.down().makePositioned();
if(window.opera) effect.element.setStyle({top:''});
effect.element.makeClipping().setStyle({height:'0px'}).show(); 
},
afterUpdateInternal:function(effect){
effect.element.down().setStyle({bottom:
(effect.dims[0] - effect.element.clientHeight)+'px'}); 
},
afterFinishInternal:function(effect){
effect.element.undoClipping().undoPositioned();
effect.element.down().undoPositioned().setStyle({bottom:oldInnerBottom});}
}, arguments[1] ||{})
);
}
Effect.SlideUp=function(element){
element=$(element).cleanWhitespace();
var oldInnerBottom=element.down().getStyle('bottom');
return new Effect.Scale(element, window.opera ? 0 :1,
Object.extend({ scaleContent:false, 
scaleX:false, 
scaleMode:'box',
scaleFrom:100,
restoreAfterFinish:true,
beforeStartInternal:function(effect){
effect.element.makePositioned();
effect.element.down().makePositioned();
if(window.opera) effect.element.setStyle({top:''});
effect.element.makeClipping().show();
},  
afterUpdateInternal:function(effect){
effect.element.down().setStyle({bottom:
(effect.dims[0] - effect.element.clientHeight)+'px'});
},
afterFinishInternal:function(effect){
effect.element.hide().undoClipping().undoPositioned().setStyle({bottom:oldInnerBottom});
effect.element.down().undoPositioned();
}
}, arguments[1] ||{})
);
}
Effect.Squish=function(element){
return new Effect.Scale(element, window.opera ? 1 :0,{ 
restoreAfterFinish:true,
beforeSetup:function(effect){
effect.element.makeClipping(); 
},  
afterFinishInternal:function(effect){
effect.element.hide().undoClipping(); 
}
});
}
Effect.Grow=function(element){
element=$(element);
var options=Object.extend({
direction:'center',
moveTransition:Effect.Transitions.sinoidal,
scaleTransition:Effect.Transitions.sinoidal,
opacityTransition:Effect.Transitions.full
}, arguments[1] ||{});
var oldStyle={
top:element.style.top,
left:element.style.left,
height:element.style.height,
width:element.style.width,
opacity:element.getInlineOpacity()};
var dims=element.getDimensions();    
var initialMoveX, initialMoveY;
var moveX, moveY;
switch (options.direction){
case 'top-left':
initialMoveX=initialMoveY=moveX=moveY=0; 
break;
case 'top-right':
initialMoveX=dims.width;
initialMoveY=moveY=0;
moveX=-dims.width;
break;
case 'bottom-left':
initialMoveX=moveX=0;
initialMoveY=dims.height;
moveY=-dims.height;
break;
case 'bottom-right':
initialMoveX=dims.width;
initialMoveY=dims.height;
moveX=-dims.width;
moveY=-dims.height;
break;
case 'center':
initialMoveX=dims.width / 2;
initialMoveY=dims.height / 2;
moveX=-dims.width / 2;
moveY=-dims.height / 2;
break;
}
return new Effect.Move(element,{
x:initialMoveX,
y:initialMoveY,
duration:0.01, 
beforeSetup:function(effect){
effect.element.hide().makeClipping().makePositioned();
},
afterFinishInternal:function(effect){
new Effect.Parallel(
[ new Effect.Opacity(effect.element,{ sync:true, to:1.0, from:0.0, transition:options.opacityTransition}),
new Effect.Move(effect.element,{ x:moveX, y:moveY, sync:true, transition:options.moveTransition}),
new Effect.Scale(effect.element, 100,{
scaleMode:{ originalHeight:dims.height, originalWidth:dims.width}, 
sync:true, scaleFrom:window.opera ? 1 :0, transition:options.scaleTransition, restoreAfterFinish:true})
], Object.extend({
beforeSetup:function(effect){
effect.effects[0].element.setStyle({height:'0px'}).show(); 
},
afterFinishInternal:function(effect){
effect.effects[0].element.undoClipping().undoPositioned().setStyle(oldStyle); 
}
}, options)
)
}
});
}
Effect.Shrink=function(element){
element=$(element);
var options=Object.extend({
direction:'center',
moveTransition:Effect.Transitions.sinoidal,
scaleTransition:Effect.Transitions.sinoidal,
opacityTransition:Effect.Transitions.none
}, arguments[1] ||{});
var oldStyle={
top:element.style.top,
left:element.style.left,
height:element.style.height,
width:element.style.width,
opacity:element.getInlineOpacity()};
var dims=element.getDimensions();
var moveX, moveY;
switch (options.direction){
case 'top-left':
moveX=moveY=0;
break;
case 'top-right':
moveX=dims.width;
moveY=0;
break;
case 'bottom-left':
moveX=0;
moveY=dims.height;
break;
case 'bottom-right':
moveX=dims.width;
moveY=dims.height;
break;
case 'center':
moveX=dims.width / 2;
moveY=dims.height / 2;
break;
}
return new Effect.Parallel(
[ new Effect.Opacity(element,{ sync:true, to:0.0, from:1.0, transition:options.opacityTransition}),
new Effect.Scale(element, window.opera ? 1 :0,{ sync:true, transition:options.scaleTransition, restoreAfterFinish:true}),
new Effect.Move(element,{ x:moveX, y:moveY, sync:true, transition:options.moveTransition})
], Object.extend({            
beforeStartInternal:function(effect){
effect.effects[0].element.makePositioned().makeClipping(); 
},
afterFinishInternal:function(effect){
effect.effects[0].element.hide().undoClipping().undoPositioned().setStyle(oldStyle);}
}, options)
);
}
Effect.Pulsate=function(element){
element=$(element);
var options   =arguments[1] ||{};
var oldOpacity=element.getInlineOpacity();
var transition=options.transition || Effect.Transitions.sinoidal;
var reverser  =function(pos){ return transition(1-Effect.Transitions.pulse(pos, options.pulses))};
reverser.bind(transition);
return new Effect.Opacity(element, 
Object.extend(Object.extend({  duration:2.0, from:0,
afterFinishInternal:function(effect){ effect.element.setStyle({opacity:oldOpacity});}
}, options),{transition:reverser}));
}
Effect.Fold=function(element){
element=$(element);
var oldStyle={
top:element.style.top,
left:element.style.left,
width:element.style.width,
height:element.style.height};
element.makeClipping();
return new Effect.Scale(element, 5, Object.extend({   
scaleContent:false,
scaleX:false,
afterFinishInternal:function(effect){
new Effect.Scale(element, 1,{ 
scaleContent:false, 
scaleY:false,
afterFinishInternal:function(effect){
effect.element.hide().undoClipping().setStyle(oldStyle);
}});
}}, arguments[1] ||{}));
};
Effect.Morph=Class.create();
Object.extend(Object.extend(Effect.Morph.prototype, Effect.Base.prototype),{
initialize:function(element){
this.element=$(element);
if(!this.element) throw(Effect._elementDoesNotExistError);
var options=Object.extend({
style:''
}, arguments[1] ||{});
this.start(options);
},
setup:function(){
function parseColor(color){
if(!color || ['rgba(0, 0, 0, 0)','transparent'].include(color)) color='#ffffff';
color=color.parseColor();
return $R(0,2).map(function(i){
return parseInt( color.slice(i*2+1,i*2+3), 16 ) 
});
}
this.transforms=this.options.style.parseStyle().map(function(property){
var originalValue=this.element.getStyle(property[0]);
return $H({ 
style:property[0], 
originalValue:property[1].unit=='color' ? 
parseColor(originalValue) :parseFloat(originalValue || 0), 
targetValue:property[1].unit=='color' ? 
parseColor(property[1].value) :property[1].value,
unit:property[1].unit
});
}.bind(this)).reject(function(transform){
return (
(transform.originalValue==transform.targetValue) ||
(
transform.unit != 'color' &&
(isNaN(transform.originalValue) || isNaN(transform.targetValue))
)
)
});
},
update:function(position){
var style=$H(), value=null;
this.transforms.each(function(transform){
value=transform.unit=='color' ?
$R(0,2).inject('#',function(m,v,i){
return m+(Math.round(transform.originalValue[i]+
(transform.targetValue[i] - transform.originalValue[i])*position)).toColorPart()}) :
transform.originalValue+Math.round(
((transform.targetValue - transform.originalValue) * position) * 1000)/1000+transform.unit;
style[transform.style]=value;
});
this.element.setStyle(style);
}
});
Effect.Transform=Class.create();
Object.extend(Effect.Transform.prototype,{
initialize:function(tracks){
this.tracks =[];
this.options=arguments[1] ||{};
this.addTracks(tracks);
},
addTracks:function(tracks){
tracks.each(function(track){
var data=$H(track).values().first();
this.tracks.push($H({
ids:$H(track).keys().first(),
effect:Effect.Morph,
options:{ style:data}
}));
}.bind(this));
return this;
},
play:function(){
return new Effect.Parallel(
this.tracks.map(function(track){
var elements=[$(track.ids) || $$(track.ids)].flatten();
return elements.map(function(e){ return new track.effect(e, Object.extend({ sync:true}, track.options))});
}).flatten(),
this.options
);
}
});
Element.CSS_PROPERTIES=['azimuth', 'backgroundAttachment', 'backgroundColor', 'backgroundImage', 
'backgroundPosition', 'backgroundRepeat', 'borderBottomColor', 'borderBottomStyle', 
'borderBottomWidth', 'borderCollapse', 'borderLeftColor', 'borderLeftStyle', 'borderLeftWidth',
'borderRightColor', 'borderRightStyle', 'borderRightWidth', 'borderSpacing', 'borderTopColor',
'borderTopStyle', 'borderTopWidth', 'bottom', 'captionSide', 'clear', 'clip', 'color', 'content',
'counterIncrement', 'counterReset', 'cssFloat', 'cueAfter', 'cueBefore', 'cursor', 'direction',
'display', 'elevation', 'emptyCells', 'fontFamily', 'fontSize', 'fontSizeAdjust', 'fontStretch',
'fontStyle', 'fontVariant', 'fontWeight', 'height', 'left', 'letterSpacing', 'lineHeight',
'listStyleImage', 'listStylePosition', 'listStyleType', 'marginBottom', 'marginLeft', 'marginRight',
'marginTop', 'markerOffset', 'marks', 'maxHeight', 'maxWidth', 'minHeight', 'minWidth', 'opacity',
'orphans', 'outlineColor', 'outlineOffset', 'outlineStyle', 'outlineWidth', 'overflowX', 'overflowY',
'paddingBottom', 'paddingLeft', 'paddingRight', 'paddingTop', 'page', 'pageBreakAfter', 'pageBreakBefore',
'pageBreakInside', 'pauseAfter', 'pauseBefore', 'pitch', 'pitchRange', 'position', 'quotes',
'richness', 'right', 'size', 'speakHeader', 'speakNumeral', 'speakPunctuation', 'speechRate', 'stress',
'tableLayout', 'textAlign', 'textDecoration', 'textIndent', 'textShadow', 'textTransform', 'top',
'unicodeBidi', 'verticalAlign', 'visibility', 'voiceFamily', 'volume', 'whiteSpace', 'widows',
'width', 'wordSpacing', 'zIndex'];
Element.CSS_LENGTH=/^(([\+\-]?[0-9\.]+)(em|ex|px|in|cm|mm|pt|pc|\%))|0$/;
String.prototype.parseStyle=function(){
var element=Element.extend(document.createElement('div'));
element.innerHTML='<div style="'+this+'"></div>';
var style=element.down().style, styleRules=$H();
Element.CSS_PROPERTIES.each(function(property){
if(style[property]) styleRules[property]=style[property]; 
});
var result=$H();
styleRules.each(function(pair){
var property=pair[0], value=pair[1], unit=null;
if(value.parseColor('#zzzzzz') != '#zzzzzz'){
value=value.parseColor();
unit ='color';
} else if(Element.CSS_LENGTH.test(value)) 
var components=value.match(/^([\+\-]?[0-9\.]+)(.*)$/),
value=parseFloat(components[1]), unit=(components.length==3) ? components[2] :null;
result[property.underscore().dasherize()]=$H({ value:value, unit:unit});
}.bind(this));
return result;
};
Element.morph=function(element, style){
new Effect.Morph(element, Object.extend({ style:style}, arguments[2] ||{}));
return element;
};
['setOpacity','getOpacity','getInlineOpacity','forceRerendering','setContentZoom',
'collectTextNodes','collectTextNodesIgnoreClass','morph'].each( 
function(f){ Element.Methods[f]=Element[f];}
);
Element.Methods.visualEffect=function(element, effect, options){
s=effect.gsub(/_/, '-').camelize();
effect_class=s.charAt(0).toUpperCase()+s.substring(1);
new Effect[effect_class](element, options);
return $(element);
};
Element.addMethods();
// Copyright (c) 2006 Sébastien Gruhier (http://xilinus.com, http://itseb.com)
// 
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// VERSION 1.0

var Window = Class.create();
Window.keepMultiModalWindow = false;
Window.prototype = {
  // Constructor
  // Available parameters : className, title, minWidth, minHeight, maxWidth, maxHeight, width, height, top, left, bottom, right, resizable, zIndex, opacity, recenterAuto, wiredDrag
  //                        hideEffect, showEffect, showEffectOptions, hideEffectOptions, effectOptions, url, draggable, closable, minimizable, maximizable, parent, onload
  initialize: function(id) {
    if ($(id))
      alert("Window " + id + " is already register is the DOM!!, be sure to use setDestroyOnClose()")
      
    this.hasEffectLib = String.prototype.parseColor != null;
    this.options = Object.extend({
      className:         "dialog",
      minWidth:          100, 
      minHeight:         20,
      resizable:         true,
      closable:          true,
      minimizable:       true,
      maximizable:       true,
      draggable:         true,
      userData:          null,
      showEffect:        (this.hasEffectLib ? Effect.Appear : Element.show),
      hideEffect:        (this.hasEffectLib ? Effect.Fade : Element.hide),
      showEffectOptions: {},
      hideEffectOptions: {},
      effectOptions:     null,
      parent:            document.body,
      title:             "&nbsp;",
      url:               null,
      onload:            Prototype.emptyFunction,
      width:             200,
      height:            300,
      opacity:           1,
      recenterAuto:      true,
      wiredDrag:         false
    }, arguments[1] || {});
        
    if (this.options.effectOptions) {
      Object.extend(this.options.hideEffectOptions, this.options.effectOptions);
      Object.extend(this.options.showEffectOptions, this.options.effectOptions);
      if (this.options.showEffect == Element.Appear)
        this.options.showEffectOptions.to = this.options.opacity;
    }
    if (this.options.showEffect == Effect.Appear)
      this.options.showEffectOptions.to = this.options.opacity;
    
    if (this.options.hideEffect == Effect.Fade)
      this.options.hideEffectOptions.from = this.options.opacity;

    if (this.options.hideEffect == Element.hide)
      this.options.hideEffect = function(){ Element.hide(this.element); if (this.destroyOnClose) this.destroy(); }.bind(this)
      
    this.element = this._createWindow(id);
    
    // Bind event listener
    this.eventMouseDown = this._initDrag.bindAsEventListener(this);
    this.eventMouseUp   = this._endDrag.bindAsEventListener(this);
    this.eventMouseMove = this._updateDrag.bindAsEventListener(this);
    this.eventOnLoad    = this._getWindowBorderSize.bindAsEventListener(this);
    this.eventMouseDownContent = this.toFront.bindAsEventListener(this);
    this.eventResize = this._recenter.bindAsEventListener(this);
 
    this.topbar = $(this.element.id + "_top");
    this.bottombar = $(this.element.id + "_bottom");
    this.content = $(this.element.id + "_content");
    
    Event.observe(this.topbar, "mousedown", this.eventMouseDown);
    Event.observe(this.bottombar, "mousedown", this.eventMouseDown);
    Event.observe(this.content, "mousedown", this.eventMouseDownContent);
    Event.observe(window, "load", this.eventOnLoad);
    Event.observe(window, "resize", this.eventResize);
    Event.observe(window, "scroll", this.eventResize);
    
    if (this.options.draggable)  {
      var that = this;
      [this.topbar, this.topbar.up().previous(), this.topbar.up().next()].each(function(element) {
        element.observe("mousedown", that.eventMouseDown);
        element.addClassName("top_draggable")
      });
      [this.bottombar, this.bottombar.up().previous(), this.bottombar.up().next()].each(function(element) {
        element.observe("mousedown", that.eventMouseDown);
        element.addClassName("bottom_draggable")
      });
      
    }    
    
    if (this.options.resizable) {
      this.sizer = $(this.element.id + "_sizer");
      Event.observe(this.sizer, "mousedown", this.eventMouseDown);
    }  
    
    this.useLeft = null;
    this.useTop = null;
    if (arguments[1].left != null) {
      this.element.setStyle({left: parseFloat(arguments[1].left) + 'px'});
      this.useLeft = true;
    }
    if (arguments[1].right != null) {
      this.element.setStyle({right: parseFloat(arguments[1].right) + 'px'});
      this.useLeft = false;
    }
    if (this.useLeft == null) {
      this.element.setStyle({left: "0px"});
      this.useLeft = true;
    }
    
    if (arguments[1].top != null) {
      this.element.setStyle({top: parseFloat(arguments[1].top) + 'px'});
      this.useTop = true;
    }
    if (arguments[1].bottom != null) {
      this.element.setStyle({bottom: parseFloat(arguments[1].bottom) + 'px'});      
      this.useTop = false;
    }
    if (this.useTop == null) {
      this.element.setStyle({top: "0px"});
      this.useTop = true;
    }
      
    this.storedLocation = null;
    
    this.setOpacity(this.options.opacity);
    if (this.options.zIndex)
      this.setZIndex(this.options.zIndex)

    this.destroyOnClose = false;

    this._getWindowBorderSize();
    this.width = this.options.width;
    this.height = this.options.height;
    this.visible = false;
    
    this.constraint = false;
    this.constraintPad = {top: 0, left:0, bottom:0, right:0};
    
    if (this.width && this.height)
      this.setSize(this.options.width, this.options.height);
    this.setTitle(this.options.title)
    Windows.register(this);      
  },
  
  // Destructor
  destroy: function() {
    Windows.notify("onDestroy", this);
    Event.stopObserving(this.topbar, "mousedown", this.eventMouseDown);
    Event.stopObserving(this.bottombar, "mousedown", this.eventMouseDown);
    Event.stopObserving(this.content, "mousedown", this.eventMouseDownContent);
    
    Event.stopObserving(window, "load", this.eventOnLoad);
    Event.stopObserving(window, "resize", this.eventResize);
    Event.stopObserving(window, "scroll", this.eventResize);
    
    Event.stopObserving(this.content, "load", this.options.onload);

    if (this._oldParent) {
      var content = this.getContent();
      var originalContent = null;
      for(var i = 0; i < content.childNodes.length; i++) {
        originalContent = content.childNodes[i];
        if (originalContent.nodeType == 1) 
          break;
        originalContent = null;
      }
      if (originalContent)
        this._oldParent.appendChild(originalContent);
      this._oldParent = null;
    }

    if (this.sizer)
        Event.stopObserving(this.sizer, "mousedown", this.eventMouseDown);

    if (this.options.url) 
      this.content.src = null

     if(this.iefix) 
      Element.remove(this.iefix);

    Element.remove(this.element);
    Windows.unregister(this);      
  },
    
  // Sets window deleagte, should have functions: "canClose(window)" 
  setDelegate: function(delegate) {
    this.delegate = delegate
  },
  
  // Gets current window delegate
  getDelegate: function() {
    return this.delegate;
  },
  
  // Gets window content
  getContent: function () {
    return this.content;
  },
  
  // Sets the content with an element id
  setContent: function(id, autoresize, autoposition) {
    var element = $(id);
    if (null == element) throw "Unable to find element '" + id + "' in DOM";
    this._oldParent = element.parentNode;

    var d = null;
    var p = null;

    if (autoresize) 
      d = Element.getDimensions(element);
    if (autoposition) 
      p = Position.cumulativeOffset(element);

    var content = this.getContent()
    content.appendChild(element);
    element.show();
    if (autoresize) 
      this.setSize(d.width, d.height);
    if (autoposition) 
      this.setLocation(p[1] - this.heightN, p[0] - this.widthW);    
  },
  
  setHTMLContent: function(html) {
    if (this.options.url) {
      
      this.content.src = null;
      this.options.url = null;
      
  	  var content ="<div id=\"" + this.getId() + "_content\" class=\"" + this.options.className + "_content\"> </div>";
      $(this.getId() +"_table_content").innerHTML = content;
      
      this.content = $(this.element.id + "_content");
    }
      
    this.getContent().innerHTML = html;
  },
  
  setAjaxContent: function(url, options, showCentered, showModal) {
    this.showFunction = showCentered ? "showCenter" : "show";
    this.showModal = showModal || false;
  
    if (options == null)
      options = {}  

    this.onComplete = options.onComplete;
    if (! this._onCompleteHandler)
      this._onCompleteHandler = this._setAjaxContent.bind(this);
    options.onComplete = this._onCompleteHandler;

    new Ajax.Request(url, options);    
    options.onComplete = this.onComplete;
  },
  
  _setAjaxContent: function(originalRequest) {
    Element.update(this.getContent(), originalRequest.responseText);
    if (this.onComplete)
      this.onComplete(originalRequest);
    this.onComplete = null;
    this[this.showFunction](this.showModal)
  },
  
  setURL: function(url) {
    // Not an url content, change div to iframe
    if (!this.options.url) {
  	  this.options.url = url;
      var content= "<iframe frameborder=\"0\" name=\"" + this.getId() + "_content\"  id=\"" + this.getId() + "_content\" src=\"" + url + "\"> </iframe>";
      $(this.getId() +"_table_content").innerHTML = content;
      
      this.content = $(this.element.id + "_content");
    } else {
  	  this.options.url = url;
	    $(this.element.getAttribute('id') + '_content').src = url;
    }
  },

  getURL: function() {
  	return this.options.url ? this.options.url : null;
  },

  refresh: function() {
    if (this.options.url)
	    $(this.element.getAttribute('id') + '_content').src = this.options.url;
  },
  
  // Stores position/size in a cookie, by default named with window id
  setCookie: function(name, expires, path, domain, secure) {
    name = name || this.element.id;
    this.cookie = [name, expires, path, domain, secure];
    
    // Get cookie
    var value = WindowUtilities.getCookie(name)
    // If exists
    if (value) {
      var values = value.split(',');
      var x = values[0].split(':');
      var y = values[1].split(':');

      var w = parseFloat(values[2]), h = parseFloat(values[3]);
      var mini = values[4];
      var maxi = values[5];

      this.setSize(w, h);
      if (mini == "true")
        this.doMinimize = true; // Minimize will be done at onload window event
      else if (maxi == "true")
        this.doMaximize = true; // Maximize will be done at onload window event

      this.useLeft = x[0] == "l";
      this.useTop = y[0] == "t";

      this.element.setStyle(this.useLeft ? {left: x[1]} : {right: x[1]});
      this.element.setStyle(this.useTop ? {top: y[1]} : {bottom: y[1]});
    }
  },
  
  // Gets window ID
  getId: function() {
    return this.element.id;
  },
  
  // Detroys itself when closing 
  setDestroyOnClose: function() {
    var destroyFunc = this.destroy.bind(this);
    if (this.options.hideEffectOptions.afterFinish) {
      var func = this.options.hideEffectOptions.afterFinish;
      this.options.hideEffectOptions.afterFinish = function() {func();destroyFunc() }
    }
    else 
      this.options.hideEffectOptions.afterFinish = function() {destroyFunc() }
    this.destroyOnClose = true;
  },
  
  setConstraint: function(bool, padding) {
    this.constraint = bool;
    this.constraintPad = Object.extend(this.constraintPad, padding || {});
    // Reset location to apply constraint
    if (this.useTop && this.useLeft)
      this.setLocation(parseFloat(this.element.style.top), parseFloat(this.element.style.left));
  },
  
  // initDrag event
  _initDrag: function(event) {
    if (isIE && this.heightN == 0)
      this._getWindowBorderSize();
    
    // Get pointer X,Y
    this.pointer = [Event.pointerX(event), Event.pointerY(event)];
    
    if (this.options.wiredDrag) 
      this.currentDrag = this._createWiredElement();
    else
      this.currentDrag = this.element;
      
    // Resize
    if (Event.element(event) == this.sizer) {
      this.doResize = true;
      this.widthOrg = this.width;
      this.heightOrg = this.height;
      this.bottomOrg = parseFloat(this.element.getStyle('bottom'));
      this.rightOrg = parseFloat(this.element.getStyle('right'));
      Windows.notify("onStartResize", this);
    }
    else {
      this.doResize = false;

      // Check if click on close button, 
      var closeButton = $(this.getId() + '_close');
      if (closeButton && Position.within(closeButton, this.pointer[0], this.pointer[1])) {
        this.currentDrag = null;
        return;
      }

      this.toFront();

      if (! this.options.draggable) 
        return;
      Windows.notify("onStartMove", this);
    }    
    // Register global event to capture mouseUp and mouseMove
    Event.observe(document, "mouseup", this.eventMouseUp, false);
    Event.observe(document, "mousemove", this.eventMouseMove, false);
    
    // Add an invisible div to keep catching mouse event over iframes
    WindowUtilities.disableScreen('__invisible__', '__invisible__');

    // Stop selection while dragging
    document.body.ondrag = function () { return false; };
    document.body.onselectstart = function () { return false; };
    
    this.currentDrag.show();
    Event.stop(event);
  },

  // updateDrag event
  _updateDrag: function(event) {
    var pointer = [Event.pointerX(event), Event.pointerY(event)];    
    var dx = pointer[0] - this.pointer[0];
    var dy = pointer[1] - this.pointer[1];
    
    // Resize case, update width/height
    if (this.doResize) {
      var w = this.widthOrg + dx;
      var h = this.heightOrg + dy;
      
      dx = this.width - this.widthOrg
      dy = this.height - this.heightOrg
      
      // Check if it's a right position, update it to keep upper-left corner at the same position
      if (this.useLeft) 
        w = this._updateWidthConstraint(w)
      else 
        this.currentDrag.setStyle({right: (this.rightOrg -dx) + 'px'});
      // Check if it's a bottom position, update it to keep upper-left corner at the same position
      if (this.useTop) 
        h = this._updateHeightConstraint(h)
      else
        this.currentDrag.setStyle({bottom: (this.bottomOrg -dy) + 'px'});
        
      this.setSize(w , h);
      Windows.notify("onResize", this);
    }
    // Move case, update top/left
    else {
      this.pointer = pointer;
      
      if (this.useLeft) {
        var left =  parseFloat(this.currentDrag.getStyle('left')) + dx;
        var newLeft = this._updateLeftConstraint(left);
        // Keep mouse pointer correct
        this.pointer[0] += newLeft-left;
        this.currentDrag.setStyle({left: newLeft + 'px'});
      }
      else 
        this.currentDrag.setStyle({right: parseFloat(this.currentDrag.getStyle('right')) - dx + 'px'});
      
      if (this.useTop) {
        var top =  parseFloat(this.currentDrag.getStyle('top')) + dy;
        var newTop = this._updateTopConstraint(top);
        // Keep mouse pointer correct
        this.pointer[1] += newTop - top;
        this.currentDrag.setStyle({top: newTop + 'px'});
      }
      else 
        this.currentDrag.setStyle({bottom: parseFloat(this.currentDrag.getStyle('bottom')) - dy + 'px'});
    }
    if (this.iefix) 
      this._fixIEOverlapping(); 
      
    this._removeStoreLocation();
    Event.stop(event);
  },

   // endDrag callback
   _endDrag: function(event) {
    // Remove temporary div over iframes
     WindowUtilities.enableScreen('__invisible__');
    
    if (this.doResize)
      Windows.notify("onEndResize", this);
    else
      Windows.notify("onEndMove", this);
    
    // Release event observing
    Event.stopObserving(document, "mouseup", this.eventMouseUp,false);
    Event.stopObserving(document, "mousemove", this.eventMouseMove, false);

    Event.stop(event);
    
    this._hideWiredElement();

    // Store new location/size if need be
    this._saveCookie()
      
    // Restore selection
    document.body.ondrag = null;
    document.body.onselectstart = null;
  },

  _updateLeftConstraint: function(left) {
    if (this.constraint && this.useLeft && this.useTop) {
      var width = this.options.parent == document.body ? WindowUtilities.getPageSize().windowWidth : this.options.parent.getDimensions().width;

      if (left < this.constraintPad.left)
        left = this.constraintPad.left;
      if (left + this.width + this.widthE + this.widthW > width - this.constraintPad.right) 
        left = width - this.constraintPad.right - this.width - this.widthE - this.widthW;
    }
    return left;
  },
  
  _updateTopConstraint: function(top) {
    if (this.constraint && this.useLeft && this.useTop) {        
      var height = this.options.parent == document.body ? WindowUtilities.getPageSize().windowHeight : this.options.parent.getDimensions().height;

      if (top < this.constraintPad.top)
        top = this.constraintPad.top;
      if (top + this.height + this.heightN + this.heightS > height - this.constraintPad.bottom) 
        top = height - this.constraintPad.bottom - this.height - this.heightS - this.heightN;
    }
    return top;
  },
  
  _updateWidthConstraint: function(w) {
    if (this.constraint && this.useLeft && this.useTop) {
      var width = this.options.parent == document.body ? WindowUtilities.getPageSize().windowWidth : this.options.parent.getDimensions().width;
      var left =  parseFloat(this.element.getStyle("left"));

      if (left + w + this.widthE + this.widthW > width - this.constraintPad.right) 
        w = width - this.constraintPad.right - left - this.widthE - this.widthW;
    }
    return w;
  },
  
  _updateHeightConstraint: function(h) {
    if (this.constraint && this.useLeft && this.useTop) {
      var height = this.options.parent == document.body ? WindowUtilities.getPageSize().windowHeight : this.options.parent.getDimensions().height;
      var top =  parseFloat(this.element.getStyle("top"));

      if (top + h + this.heightN + this.heightS > height - this.constraintPad.bottom) 
        h = height - this.constraintPad.bottom - top - this.heightN - this.heightS;
    }
    return h;
  },
  
  
  // Creates HTML window code
  _createWindow: function(id) {
    var className = this.options.className;
    var win = document.createElement("div");
    win.setAttribute('id', id);
    win.className = "dialog";

    var content;
    if (this.options.url)
      content= "<iframe frameborder=\"0\" name=\"" + id + "_content\"  id=\"" + id + "_content\" src=\"" + this.options.url + "\"> </iframe>";
    else
      content ="<div id=\"" + id + "_content\" class=\"" +className + "_content\"> </div>";

    var closeDiv = this.options.closable ? "<div class='"+ className +"_close' id='"+ id +"_close' onclick='Windows.close(\""+ id +"\", event)'> </div>" : "";
    var minDiv = this.options.minimizable ? "<div class='"+ className + "_minimize' id='"+ id +"_minimize' onclick='Windows.minimize(\""+ id +"\", event)'> </div>" : "";
    var maxDiv = this.options.maximizable ? "<div class='"+ className + "_maximize' id='"+ id +"_maximize' onclick='Windows.maximize(\""+ id +"\", event)'> </div>" : "";
    var seAttributes = this.options.resizable ? "class='" + className + "_sizer' id='" + id + "_sizer'" : "class='"  + className + "_se'";
    
    win.innerHTML = closeDiv + minDiv + maxDiv + "\
      <table id='"+ id +"_row1' class=\"top table_window\">\
        <tr>\
          <td class='"+ className +"_nw'>&nbsp;</td>\
          <td class='"+ className +"_n'><div id='"+ id +"_top' class='"+ className +"_title title_window'>"+ this.options.title +"</div></td>\
          <td class='"+ className +"_ne'>&nbsp;</td>\
        </tr>\
      </table>\
      <table id='"+ id +"_row2' class=\"mid table_window\">\
        <tr>\
          <td class='"+ className +"_w'></td>\
            <td id='"+ id +"_table_content' class='"+ className +"_content' valign='top'>" + content + "</td>\
          <td class='"+ className +"_e'></td>\
        </tr>\
      </table>\
        <table id='"+ id +"_row3' class=\"bot table_window\">\
        <tr>\
          <td class='"+ className +"_sw'>&nbsp;</td>\
            <td class='"+ className +"_s'><div id='"+ id +"_bottom' class='status_bar'>&nbsp;</div></td>\
            <td " + seAttributes + ">&nbsp;</td>\
        </tr>\
      </table>\
    ";
    Element.hide(win);
    this.options.parent.insertBefore(win, this.options.parent.firstChild);
    Event.observe($(id + "_content"), "load", this.options.onload);
    return win;
  },
  
  
  changeClassName: function(newClassName) {
    var className = this.options.className;
    var id = this.getId();
    var win = this;
    $A(["_close","_minimize","_maximize","_sizer", "_content"]).each(function(value) { win._toggleClassName($(id + value), className + value, newClassName + value) });
    $$("#" + id + " td").each(function(td) {td.className = td.className.sub(className,newClassName) });
    this.options.className = newClassName;
  },
  
  _toggleClassName: function(element, oldClassName, newClassName) {
    if (element) {
      element.removeClassName(oldClassName);
      element.addClassName(newClassName);
    }
  },
  
  // Sets window location
  setLocation: function(top, left) {
    top = this._updateTopConstraint(top);
    left = this._updateLeftConstraint(left);

    this.element.setStyle({top: top + 'px'});
    this.element.setStyle({left: left + 'px'});

    this.useLeft = true;
    this.useTop = true;
  },
    
  getLocation: function() {
    var location = {};
    if (this.useTop)
      location = Object.extend(location, {top: this.element.getStyle("top")});
    else
      location = Object.extend(location, {bottom: this.element.getStyle("bottom")});
    if (this.useLeft)
      location = Object.extend(location, {left: this.element.getStyle("left")});
    else
      location = Object.extend(location, {right: this.element.getStyle("right")});
    
    return location;
  },
  
  // Gets window size
  getSize: function() {
    return {width: this.width, height: this.height};
  },
    
  // Sets window size
  setSize: function(width, height) {    
    width = parseFloat(width);
    height = parseFloat(height);
    
    // Check min and max size
    if (width < this.options.minWidth)
      width = this.options.minWidth;

    if (height < this.options.minHeight)
      height = this.options.minHeight;
      
    if (this.options. maxHeight && height > this.options. maxHeight)
      height = this.options. maxHeight;

    if (this.options. maxWidth && width > this.options. maxWidth)
      width = this.options. maxWidth;

    this.width = width;
    this.height = height;
    var e = this.currentDrag ? this.currentDrag : this.element;
    e.setStyle({width: width + this.widthW + this.widthE + "px"})
    e.setStyle({height: height  + this.heightN + this.heightS + "px"})

    // Update content height
    if (!this.currentDrag || this.currentDrag == this.element) {
      var content = $(this.element.id + '_content');
      content.setStyle({height: height  + 'px'});
      content.setStyle({width: width  + 'px'});
    }
  },
  
  updateHeight: function() {
    this.setSize(this.width, this.content.scrollHeight)
  },
  
  updateWidth: function() {
    this.setSize(this.content.scrollWidth, this.height)
  },
  
  // Brings window to front
  toFront: function() {
    if (Windows.focusedWindow == this) 
      return;
    this.setZIndex(Windows.maxZIndex + 20);
    Windows.notify("onFocus", this);
  },
  
  // Displays window modal state or not
  show: function(modal) {
    if (modal) {
      Windows.addModalWindow(this);
      
      this.modal = true;      
      this.setZIndex(Windows.maxZIndex + 20);
      Windows.unsetOverflow(this);
    }
    
    // To restore overflow if need be
    if (this.oldStyle)
      this.getContent().setStyle({overflow: this.oldStyle});
      
    if (! this.width || !this.height) {
      var size = WindowUtilities._computeSize(this.content.innerHTML, this.content.id, this.width, this.height, 0, this.options.className)
      if (this.height)
        this.width = size + 5
      else
        this.height = size + 5
    }

    this.setSize(this.width, this.height);
    if (this.centered)
      this._center(this.centerTop, this.centerLeft);    
    
    Windows.notify("onBeforeShow", this);    
    if (this.options.showEffect != Element.show && this.options.showEffectOptions )
      this.options.showEffect(this.element, this.options.showEffectOptions);  
    else
      this.options.showEffect(this.element);  
      
    this._checkIEOverlapping();
    this.visible = true;
    WindowUtilities.focusedWindow = this
    Windows.notify("onShow", this);    
  },
  
  // Displays window modal state or not at the center of the page
  showCenter: function(modal, top, left) {
    this.centered = true;
    this.centerTop = top;
    this.centerLeft = left;

    this.show(modal);
  },
  
  isVisible: function() {
    return this.visible;
  },
  
  _center: function(top, left) {
    var windowScroll = WindowUtilities.getWindowScroll();    
    var pageSize = WindowUtilities.getPageSize();    

    if (!top)
      top = (pageSize.windowHeight - (this.height + this.heightN + this.heightS))/2;
    top += windowScroll.top
    
    if (!left)
      left = (pageSize.windowWidth - (this.width + this.widthW + this.widthE))/2;
    left += windowScroll.left 
    
    this.setLocation(top, left);
    this.toFront();
  },
  
  _recenter: function(event) {
    if (this.modal && this.centered) {
      var pageSize = WindowUtilities.getPageSize();
      // Check for this stupid IE that sends dumb events
      if (this.pageSize && this.pageSize.pageWidth == pageSize.windowWidth && this.pageSize.pageHeight == pageSize.windowHeight) 
        return;
      
      this.pageSize = pageSize;
      // set height of Overlay to take up whole page and show
      if ($('overlay_modal')) {
        $('overlay_modal').style.height = (pageSize.pageHeight + 'px');
        $('overlay_modal').style.width = (pageSize.pageWidth + 'px');
      }    
      if (this.options.recenterAuto)
        this._center(this.centerTop, this.centerLeft);    
    }
  },
  
  // Hides window
  hide: function() {
    this.visible = false;
    if (this.modal) {
      Windows.removeModalWindow(this);
      Windows.resetOverflow();
    }
    // To avoid bug on scrolling bar
    this.oldStyle = this.getContent().getStyle('overflow') || "auto"
    this.getContent().setStyle({overflow: "hidden"});

    this.options.hideEffect(this.element, this.options.hideEffectOptions);  

     if(this.iefix) 
      this.iefix.hide();
    Windows.notify("onHide", this);
  },

  minimize: function() {
    var r2 = $(this.getId() + "_row2");
    var dh = r2.getDimensions().height;
    
    if (r2.visible()) {
      var h  = this.element.getHeight() - dh
      r2.hide()
      this.element.setStyle({height: h + "px"})
      if (! this.useTop) {
        var bottom = parseFloat(this.element.getStyle('bottom'));
        this.element.setStyle({bottom: (bottom + dh) + 'px'});
      }
    } 
    else {
      var h  = this.element.getHeight() + dh;
      this.element.setStyle({height: h + "px"})
      if (! this.useTop) {
        var bottom = parseFloat(this.element.getStyle('bottom'));
        this.element.setStyle({bottom: (bottom - dh) + 'px'});
      }
      r2.show();
      
      this.toFront();
    }
    Windows.notify("onMinimize", this);
    
    // Store new location/size if need be
    this._saveCookie()
  },
  
  maximize: function() {
    if (this.storedLocation != null) {
      this._restoreLocation();
      if(this.iefix) 
        this.iefix.hide();
    }
    else {
      this._storeLocation();
      Windows.unsetOverflow(this);
      
      var windowScroll = WindowUtilities.getWindowScroll();
      var pageSize = WindowUtilities.getPageSize();    

      this.element.setStyle(this.useLeft ? {left: windowScroll.left} : {right: windowScroll.left});
      this.element.setStyle(this.useTop ? {top: windowScroll.top} : {bottom: windowScroll.top});

      this.setSize(pageSize.windowWidth - this.widthW - this.widthE, pageSize.windowHeight - this.heightN - this.heightS)
      this.toFront();
      if (this.iefix) 
        this._fixIEOverlapping(); 
    }
    Windows.notify("onMaximize", this);

    // Store new location/size if need be
    this._saveCookie()
  },
  
  isMinimized: function() {
    var r2 = $(this.getId() + "_row2");
    return !r2.visible();
  },
  
  isMaximized: function() {
    return (this.storedLocation != null);
  },
  
  setOpacity: function(opacity) {
    if (Element.setOpacity)
      Element.setOpacity(this.element, opacity);
  },
  
  setZIndex: function(zindex) {
    this.element.setStyle({zIndex: zindex});
    Windows.updateZindex(zindex, this);
  },

  setTitle: function(newTitle) {
    if (!newTitle || newTitle == "") 
      newTitle = "&nbsp;";
      
    Element.update(this.element.id + '_top', newTitle);
  },

  setStatusBar: function(element) {
    var statusBar = $(this.getId() + "_bottom");

    if (typeof(element) == "object") {
      if (this.bottombar.firstChild)
        this.bottombar.replaceChild(element, this.bottombar.firstChild);
      else
        this.bottombar.appendChild(element);
    }
    else
      this.bottombar.innerHTML = element;
  },

  _checkIEOverlapping: function() {
    if(!this.iefix && (navigator.appVersion.indexOf('MSIE')>0) && (navigator.userAgent.indexOf('Opera')<0) && (this.element.getStyle('position')=='absolute')) {
        new Insertion.After(this.element.id, '<iframe id="' + this.element.id + '_iefix" '+ 'style="display:none;position:absolute;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);" ' + 'src="javascript:false;" frameborder="0" scrolling="no"></iframe>');
        this.iefix = $(this.element.id+'_iefix');
    }
    if(this.iefix) 
      setTimeout(this._fixIEOverlapping.bind(this), 50);
  },

  _fixIEOverlapping: function() {
      Position.clone(this.element, this.iefix);
      this.iefix.style.zIndex = this.element.style.zIndex - 1;
      this.iefix.show();
  },
  
  _getWindowBorderSize: function(event) {
    // Hack to get real window border size!!
    var div = this._createHiddenDiv(this.options.className + "_n")
    this.heightN = Element.getDimensions(div).height;    
    div.parentNode.removeChild(div)

    var div = this._createHiddenDiv(this.options.className + "_s")
    this.heightS = Element.getDimensions(div).height;    
    div.parentNode.removeChild(div)

    var div = this._createHiddenDiv(this.options.className + "_e")
    this.widthE = Element.getDimensions(div).width;    
    div.parentNode.removeChild(div)

    var div = this._createHiddenDiv(this.options.className + "_w")
    this.widthW = Element.getDimensions(div).width;
    div.parentNode.removeChild(div);

    // Workaround for IE!!
    if (isIE) {
      this.heightS = $(this.getId() +"_row3").getDimensions().height;
      this.heightN = $(this.getId() +"_row1").getDimensions().height;
    }

    // Safari size fix
    if (/Konqueror|Safari|KHTML/.test(navigator.userAgent))
      this.setSize(this.width, this.height);
    if (this.doMaximize)
      this.maximize();
    if (this.doMinimize)
      this.minimize();
  },
 
  _createHiddenDiv: function(className) {
    var objBody = document.body;
    var win = document.createElement("div");
    win.setAttribute('id', this.element.id+ "_tmp");
    win.className = className;
    win.style.display = 'none';
    win.innerHTML = '';
    objBody.insertBefore(win, objBody.firstChild);
    return win;
  },
  
  _storeLocation: function() {
    if (this.storedLocation == null) {
      this.storedLocation = {useTop: this.useTop, useLeft: this.useLeft, 
                             top: this.element.getStyle('top'), bottom: this.element.getStyle('bottom'),
                             left: this.element.getStyle('left'), right: this.element.getStyle('right'),
                             width: this.width, height: this.height };
    }
  },
  
  _restoreLocation: function() {
    if (this.storedLocation != null) {
      this.useLeft = this.storedLocation.useLeft;
      this.useTop = this.storedLocation.useTop;
      
      this.element.setStyle(this.useLeft ? {left: this.storedLocation.left} : {right: this.storedLocation.right});
      this.element.setStyle(this.useTop ? {top: this.storedLocation.top} : {bottom: this.storedLocation.bottom});
      this.setSize(this.storedLocation.width, this.storedLocation.height);
      
      Windows.resetOverflow();
      this._removeStoreLocation();
    }
  },
  
  _removeStoreLocation: function() {
    this.storedLocation = null;
  },
  
  _saveCookie: function() {
    if (this.cookie) {
      var value = "";
      if (this.useLeft)
        value += "l:" +  (this.storedLocation ? this.storedLocation.left : this.element.getStyle('left'))
      else
        value += "r:" + (this.storedLocation ? this.storedLocation.right : this.element.getStyle('right'))
      if (this.useTop)
        value += ",t:" + (this.storedLocation ? this.storedLocation.top : this.element.getStyle('top'))
      else
        value += ",b:" + (this.storedLocation ? this.storedLocation.bottom :this.element.getStyle('bottom'))
        
      value += "," + (this.storedLocation ? this.storedLocation.width : this.width);
      value += "," + (this.storedLocation ? this.storedLocation.height : this.height);
      value += "," + this.isMinimized();
      value += "," + this.isMaximized();
      WindowUtilities.setCookie(value, this.cookie)
    }
  },
  
  _createWiredElement: function() {
    if (! this.wiredElement) {
      if (isIE)
        this._getWindowBorderSize();
      var div = document.createElement("div");
      div.className = "wired_frame " + this.options.className + "_wired_frame";
      
      //div.style.display = "none";
      div.style.position = 'absolute';
      document.body.insertBefore(div, document.body.firstChild);
      div = $(div);

      var dim = this.element.getDimensions();
      div.setStyle({width: dim.width + "px", height: dim.height +"px"});

      if (this.useLeft) 
        div.setStyle({left: this.element.getStyle('left')});
      else 
        div.setStyle({right: this.element.getStyle('right')});
        
      if (this.useTop) 
        div.setStyle({top: this.element.getStyle('top')});
      else 
        div.setStyle({bottom: this.element.getStyle('bottom')});
      this.wiredElement = div
    }
    this.wiredElement.setStyle({zIndex: Windows.maxZIndex+30});
    return this.wiredElement;
  },
  
  _hideWiredElement: function() {
    if (! this.wiredElement)
      return;
    if (this.currentDrag == this.element) 
      this.currentDrag = null;
    else {
      if (this.useLeft) 
        this.element.setStyle({left: this.currentDrag.getStyle('left')});
      else 
        this.element.setStyle({right: this.currentDrag.getStyle('right')});

      if (this.useTop) 
        this.element.setStyle({top: this.currentDrag.getStyle('top')});
      else 
        this.element.setStyle({bottom: this.currentDrag.getStyle('bottom')});

      this.currentDrag.hide();
      this.currentDrag = null;
      this.setSize(this.width, this.height);
    } 
  }
};

// Windows containers, register all page windows
var Windows = {
  windows: [],
  modalWindows: [],
  observers: [],
  focusedWindow: null,
  maxZIndex: 0,

  addObserver: function(observer) {
    this.removeObserver(observer);
    this.observers.push(observer);
  },
  
  removeObserver: function(observer) {  
    this.observers = this.observers.reject( function(o) { return o==observer });
  },
  
  notify: function(eventName, win) {  //  onStartResize(), onEndResize(), onStartMove(), onEndMove(), onClose(), onDestroy(), onMinimize(), onMaximize(), onHide(), onShow(), onFocus()
    this.observers.each( function(o) {if(o[eventName]) o[eventName](eventName, win);});
  },

  // Gets window from its id
  getWindow: function(id) {
    return this.windows.detect(function(d) { return d.getId() ==id });
  },

  // Gets the last focused window
  getFocusedWindow: function() {
    return this.focusedWindow;
  },

  // Registers a new window (called by Windows constructor)
  register: function(win) {
    this.windows.push(win);
  },
    
  // Add a modal window in the stack
  addModalWindow: function(win) {
    // Disable screen if first modal window
    if (this.modalWindows.length == 0)
      WindowUtilities.disableScreen(win.options.className, 'overlay_modal', win.getId());
    else {
      // Move overlay over all windows
      if (Window.keepMultiModalWindow) {
        $('overlay_modal').style.zIndex = Windows.maxZIndex + 20;
        Windows.maxZIndex += 20;
        WindowUtilities._hideSelect(this.modalWindows.last().getId());
      }
      // Hide current modal window
      else
        this.modalWindows.last().element.hide();
      // Fucking IE select issue
      WindowUtilities._showSelect(win.getId());
    }      
    this.modalWindows.push(win);    
  },
  
  removeModalWindow: function(win) {
    this.modalWindows.pop();
    
    // No more modal windows
    if (this.modalWindows.length == 0)
      WindowUtilities.enableScreen();     
    else {
      if (Window.keepMultiModalWindow) {
        this.modalWindows.last().toFront();
        WindowUtilities._showSelect(this.modalWindows.last().getId());        
      }
      else
        this.modalWindows.last().element.show();
    }
  },
  
  // Registers a new window (called by Windows constructor)
  register: function(win) {
    this.windows.push(win);
  },
  
  // Unregisters a window (called by Windows destructor)
  unregister: function(win) {
    this.windows = this.windows.reject(function(d) { return d==win });
  }, 

  // Closes a window with its id
  close: function(id, event) {
    var win = this.getWindow(id);
    // Asks delegate if exists
    if (win && win.visible) {
      if (win.getDelegate() && ! win.getDelegate().canClose(win)) 
        return;
      this.focusedWindow = this.windows.length >=2 ? this.windows[this.windows.length-2] : null;
      this.notify("onClose", win);
      win.hide();
    }
    if (event)
      Event.stop(event);
  },
  
  // Closes all windows
  closeAll: function() {  
    this.windows.each( function(w) {Windows.close(w.getId())} );
  },
  
  closeAllModalWindows: function() {
    WindowUtilities.enableScreen();     
    
    this.modalWindows.each( function(win) {win.hide()});    
  },
  // Minimizes a window with its id
  minimize: function(id, event) {
    var win = this.getWindow(id)
    if (win && win.visible)
      win.minimize();
    Event.stop(event);
  },
  
  // Maximizes a window with its id
  maximize: function(id, event) {
    var win = this.getWindow(id)
    if (win && win.visible)
      win.maximize();
    Event.stop(event);
  },
  
  unsetOverflow: function(except) {    
    this.windows.each(function(d) { d.oldOverflow = d.getContent().getStyle("overflow") || "auto" ; d.getContent().setStyle({overflow: "hidden"}) });
    if (except && except.oldOverflow)
      except.getContent().setStyle({overflow: except.oldOverflow});
  },

  resetOverflow: function() {
    this.windows.each(function(d) { if (d.oldOverflow) d.getContent().setStyle({overflow: d.oldOverflow}) });
  },

  updateZindex: function(zindex, win) {
    if (zindex > this.maxZIndex)
      this.maxZIndex = zindex;
    this.focusedWindow = win;
  }
};

var Dialog = {
  dialogId: null,
  onCompleteFunc: null,
  callFunc: null, 
  parameters: null, 
    
  confirm: function(content, parameters) {
    // Get Ajax return before
    if (typeof content != "string") {
      Dialog._runAjaxRequest(content, parameters, Dialog.confirm);
      return 
    }
    
    parameters = parameters || {};
    var okLabel = parameters.okLabel ? parameters.okLabel : "Ok";
    var cancelLabel = parameters.cancelLabel ? parameters.cancelLabel : "Cancel";

    var windowParam = parameters.windowParameters || {};
    windowParam.className = windowParam.className || "alert";

    var okButtonClass = "class ='" + (parameters.buttonClass ? parameters.buttonClass + " " : "") + " ok_button'" 
    var cancelButtonClass = "class ='" + (parameters.buttonClass ? parameters.buttonClass + " " : "") + " cancel_button'" 
    var content = "\
      <div class='" + windowParam.className + "_message'>" + content  + "</div>\
        <div class='" + windowParam.className + "_buttons'>\
          <input type='button' value='" + okLabel + "' onclick='Dialog.okCallback()'" + okButtonClass + "/>\
          <input type='button' value='" + cancelLabel + "' onclick='Dialog.cancelCallback()' " + cancelButtonClass + "/>\
        </div>\
    ";
    return this._openDialog(content, parameters, windowParam.className)
  },
  
  alert: function(content, parameters) {
    // Get Ajax return before
    if (typeof content != "string") {
      Dialog._runAjaxRequest(content, parameters, Dialog.alert);
      return 
    }
    
    parameters = parameters || {};
    var okLabel = parameters.okLabel ? parameters.okLabel : "Ok";

    var windowParam = parameters.windowParameters || {};
    windowParam.className = windowParam.className || "alert";

    var okButtonClass = "class ='" + (parameters.buttonClass ? parameters.buttonClass + " " : "") + " ok_button'" 
    var content = "\
      <div class='" + windowParam.className + "_message'>" + content  + "</div>\
        <div class='" + windowParam.className + "_buttons'>\
          <input type='button' value='" + okLabel + "' onclick='Dialog.okCallback()'" + okButtonClass + "/>\
        </div>";
    return this._openDialog(content, parameters, windowParam.className)
  },
  
  info: function(content, parameters) {   
    // Get Ajax return before
    if (typeof content != "string") {
      Dialog._runAjaxRequest(content, parameters, Dialog.info);
      return 
    }
     
    parameters = parameters || {};
    parameters.windowParameters = parameters.windowParameters || {};
    
    var className = parameters.windowParameters.className || "alert";

    var content = "<div id='modal_dialog_message' class='" + className + "_message'>" + content  + "</div>";
    if (parameters.showProgress)
      content += "<div id='modal_dialog_progress' class='" + className + "_progress'>  </div>";

    parameters.windowParameters.ok = null;
    parameters.windowParameters.cancel = null;
    parameters.windowParameters.className = className;
    
    return this._openDialog(content, parameters, className)
  },
  
  setInfoMessage: function(message) {
    $('modal_dialog_message').update(message);
  },
  
  closeInfo: function() {
    Windows.close(this.dialogId);
  },
  
  _openDialog: function(content, parameters, className) {
    if (! parameters.windowParameters.height && ! parameters.windowParameters.width) {
      parameters.windowParameters.width = WindowUtilities.getPageSize().pageWidth / 2;
    }
    if (parameters.id)
      this.dialogId = parameters.id;
    else { 
      var t = new Date();
      this.dialogId = 'modal_dialog_' + t.getTime();
    }

    // compute height or width if need be
    if (! parameters.windowParameters.height || ! parameters.windowParameters.width) {
      var size = WindowUtilities._computeSize(content, this.dialogId, parameters.windowParameters.width, parameters.windowParameters.height, 5, className)
      if (parameters.windowParameters.height)
        parameters.windowParameters.width = size + 5
      else
        parameters.windowParameters.height = size + 5
    }
    var windowParam = parameters && parameters.windowParameters ? parameters.windowParameters : {};
    windowParam.resizable = windowParam.resizable || false;
    
    windowParam.effectOptions = windowParam.effectOptions || {duration: 1};
    windowParam.minimizable = false;
    windowParam.maximizable = false;
    windowParam.closable = false;
    
    var win = new Window(this.dialogId, windowParam);
    win.getContent().innerHTML = content;
    win.showCenter(true, parameters.top, parameters.left);  
    win.setDestroyOnClose();
    
    win.cancelCallback = parameters.cancel;
    win.okCallback = parameters.ok;
    
    return win;    
  },
  
  _getAjaxContent: function(originalRequest)  {
      Dialog.callFunc(originalRequest.responseText, Dialog.parameters)
  },
  
  _runAjaxRequest: function(message, parameters, callFunc) {
    if (message.options == null)
      message.options ={}  
    Dialog.onCompleteFunc = message.options.onComplete;
    Dialog.parameters = parameters;
    Dialog.callFunc = callFunc;
    
    message.options.onComplete = Dialog._getAjaxContent;
    new Ajax.Request(message.url, message.options);
  },
  
  okCallback: function() {
    var win = Windows.focusedWindow;
    if (!win.okCallback || win.okCallback(win)) {
      // Remove onclick on button
      $$("#" + win.getId()+" input").each(function(element) {element.onclick=null;})
      win.hide();
    }
  },

  cancelCallback: function() {
    var win = Windows.focusedWindow;
    // Remove onclick on button
    $$("#" + win.getId()+" input").each(function(element) {element.onclick=null})
    win.hide();
    if (win.cancelCallback)
      win.cancelCallback(win);
  }
}
/*
  Based on Lightbox JS: Fullsize Image Overlays 
  by Lokesh Dhakar - http://www.huddletogether.com

  For more information on this script, visit:
  http://huddletogether.com/projects/lightbox/

  Licensed under the Creative Commons Attribution 2.5 License - http://creativecommons.org/licenses/by/2.5/
  (basically, do anything you want, just leave my name and link)
*/

var isIE = navigator.appVersion.match(/MSIE/) == "MSIE";

var WindowUtilities = {
  // From script.aculo.us
  getWindowScroll: function() {
    var w = window;
      var T, L, W, H;
      with (w.document) {
        if (w.document.documentElement && documentElement.scrollTop) {
          T = documentElement.scrollTop;
          L = documentElement.scrollLeft;
        } else if (w.document.body) {
          T = body.scrollTop;
          L = body.scrollLeft;
        }
        if (w.innerWidth) {
          W = w.innerWidth;
          H = w.innerHeight;
        } else if (w.document.documentElement && documentElement.clientWidth) {
          W = documentElement.clientWidth;
          H = documentElement.clientHeight;
        } else {
          W = body.offsetWidth;
          H = body.offsetHeight
        }
      }
      return { top: T, left: L, width: W, height: H };
    
  }, 
  //
  // getPageSize()
  // Returns array with page width, height and window width, height
  // Core code from - quirksmode.org
  // Edit for Firefox by pHaez
  //
  getPageSize: function(){
    var xScroll, yScroll;

    if (window.innerHeight && window.scrollMaxY) {  
      xScroll = document.body.scrollWidth;
      yScroll = window.innerHeight + window.scrollMaxY;
    } else if (document.body.scrollHeight > document.body.offsetHeight){ // all but Explorer Mac
      xScroll = document.body.scrollWidth;
      yScroll = document.body.scrollHeight;
    } else { // Explorer Mac...would also work in Explorer 6 Strict, Mozilla and Safari
      xScroll = document.body.offsetWidth;
      yScroll = document.body.offsetHeight;
    }

    var windowWidth, windowHeight;

    if (self.innerHeight) {  // all except Explorer
      windowWidth = self.innerWidth;
      windowHeight = self.innerHeight;
    } else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
      windowWidth = document.documentElement.clientWidth;
      windowHeight = document.documentElement.clientHeight;
    } else if (document.body) { // other Explorers
      windowWidth = document.body.clientWidth;
      windowHeight = document.body.clientHeight;
    }  
    var pageHeight, pageWidth;

    // for small pages with total height less then height of the viewport
    if(yScroll < windowHeight){
      pageHeight = windowHeight;
    } else { 
      pageHeight = yScroll;
    }

    // for small pages with total width less then width of the viewport
    if(xScroll < windowWidth){  
      pageWidth = windowWidth;
    } else {
      pageWidth = xScroll;
    }

    return {pageWidth: pageWidth ,pageHeight: pageHeight , windowWidth: windowWidth, windowHeight: windowHeight};
  },

   disableScreen: function(className, overlayId, contentId) {
    WindowUtilities.initLightbox(overlayId, className);
    var objBody = document.body;

    // prep objects
     var objOverlay = $(overlayId);

    var pageSize = WindowUtilities.getPageSize();

    // Hide select boxes as they will 'peek' through the image in IE, store old value
    if (contentId && isIE) {
      WindowUtilities._hideSelect();
      WindowUtilities._showSelect(contentId);
    }  
  
    // set height of Overlay to take up whole page and show
    objOverlay.style.height = (pageSize.pageHeight + 'px');
    objOverlay.style.width = (pageSize.windowWidth + 'px');
    objOverlay.style.display = 'block';  
  },

   enableScreen: function(id) {
     id = id || 'overlay_modal';
     var objOverlay =  $(id);
    if (objOverlay) {
      // hide lightbox and overlay
      objOverlay.style.display = 'none';

      // make select boxes visible using old value
      if (id != "__invisible__") 
        WindowUtilities._showSelect();
      
      objOverlay.parentNode.removeChild(objOverlay);
    }
  },

  _hideSelect: function(id) {
    if (isIE) {
      id = id ==  null ? "" : "#" + id + " ";
      $$(id + 'select').each(function(element) {
        if (! WindowUtilities.isDefined(element.oldVisibility)) {
          element.oldVisibility = element.style.visibility ? element.style.visibility : "visible";
          element.style.visibility = "hidden";
        }
      });
    }
  },
  
  _showSelect: function(id) {
    if (isIE) {
      id = id ==  null ? "" : "#" + id + " ";
      $$(id + 'select').each(function(element) {
        if (WindowUtilities.isDefined(element.oldVisibility)) {
          // Why?? Ask IE
          try {
            element.style.visibility = element.oldVisibility;
          } catch(e) {
            element.style.visibility = "visible";
          }
          element.oldVisibility = null;
        }
        else {
          if (element.style.visibility)
            element.style.visibility = "visible";
        }
      });
    }
  },

  isDefined: function(object) {
    return typeof(object) != "undefined" && object != null;
  },
  
  // initLightbox()
  // Function runs on window load, going through link tags looking for rel="lightbox".
  // These links receive onclick events that enable the lightbox display for their targets.
  // The function also inserts html markup at the top of the page which will be used as a
  // container for the overlay pattern and the inline image.
  initLightbox: function(id, className) {
    // Already done, just update zIndex
    if ($(id)) {
      Element.setStyle(id, {zIndex: Windows.maxZIndex + 10});
    }
    // create overlay div and hardcode some functional styles (aesthetic styles are in CSS file)
    else {
      var objBody = document.body;
      var objOverlay = document.createElement("div");
      objOverlay.setAttribute('id', id);
      objOverlay.className = "overlay_" + className
      objOverlay.style.display = 'none';
      objOverlay.style.position = 'absolute';
      objOverlay.style.top = '0';
      objOverlay.style.left = '0';
      objOverlay.style.zIndex = Windows.maxZIndex + 10;
       objOverlay.style.width = '100%';
      objBody.insertBefore(objOverlay, objBody.firstChild);
    }
  },
  
  setCookie: function(value, parameters) {
    document.cookie= parameters[0] + "=" + escape(value) +
      ((parameters[1]) ? "; expires=" + parameters[1].toGMTString() : "") +
      ((parameters[2]) ? "; path=" + parameters[2] : "") +
      ((parameters[3]) ? "; domain=" + parameters[3] : "") +
      ((parameters[4]) ? "; secure" : "");
  },

  getCookie: function(name) {
    var dc = document.cookie;
    var prefix = name + "=";
    var begin = dc.indexOf("; " + prefix);
    if (begin == -1) {
      begin = dc.indexOf(prefix);
      if (begin != 0) return null;
    } else {
      begin += 2;
    }
    var end = document.cookie.indexOf(";", begin);
    if (end == -1) {
      end = dc.length;
    }
    return unescape(dc.substring(begin + prefix.length, end));
  },
    
  _computeSize: function(content, id, width, height, margin, className) {
    var objBody = document.body;
    var tmpObj = document.createElement("div");
    tmpObj.setAttribute('id', id);
    tmpObj.className = className + "_content";

    if (height)
      tmpObj.style.height = height + "px"
    else
      tmpObj.style.width = width + "px"
  
    tmpObj.style.position = 'absolute';
    tmpObj.style.top = '0';
    tmpObj.style.left = '0';
    tmpObj.style.display = 'none';

    tmpObj.innerHTML = content;
    objBody.insertBefore(tmpObj, objBody.firstChild);
    
    var size;
    if (height)
      size = $(id).getDimensions().width + margin;
    else
      size = $(id).getDimensions().height + margin;
    objBody.removeChild(tmpObj);
    return size;
  }  
}


<%=packageName%>
<% import grails.persistence.Event %>

<%  excludedProps = Event.allEvents.toList() << 'version' << 'dateCreated' << 'lastUpdated'

	hiddenFields = ['cadastradoPor']

	persistentPropNames = domainClass.persistentProperties*.name
	boolean hasHibernate = pluginManager?.hasGrailsPlugin('hibernate') || pluginManager?.hasGrailsPlugin('hibernate4')
	if (hasHibernate) {
		def GrailsDomainBinder = getClass().classLoader.loadClass('org.codehaus.groovy.grails.orm.hibernate.cfg.GrailsDomainBinder')
		if (GrailsDomainBinder.newInstance().getMapping(domainClass)?.identity?.generator == 'assigned') {
			persistentPropNames << domainClass.identifier.name
		}
	}
	props = domainClass.properties.findAll { persistentPropNames.contains(it.name) && !excludedProps.contains(it.name) && (domainClass.constrainedProperties[it.name] ? domainClass.constrainedProperties[it.name].display : true) }
	Collections.sort(props, comparator.constructors[0].newInstance([domainClass] as Object[]))
	for (p in props) {
		def cpTemp = domainClass.constrainedProperties[p.name]
		boolean isVisible = cpTemp?.attributes?.showInForm != null?cpTemp?.attributes?.showInForm:true
		if(isVisible){
			if (p.embedded) {
				def embeddedPropNames = p.component.persistentProperties*.name
				def embeddedProps = p.component.properties.findAll { embeddedPropNames.contains(it.name) && !excludedProps.contains(it.name) }
				Collections.sort(embeddedProps, comparator.constructors[0].newInstance([p.component] as Object[]))
				%><fieldset class="embedded"><legend><g:message code="${domainClass.propertyName}.${p.name}.label" default="${p.naturalName}" /></legend><%
					for (ep in p.component.properties) {
						renderFieldForProperty(ep, p.component, "${p.name}.")
					}
				%></fieldset><%
			} else {
				renderFieldForProperty(p, domainClass)
			}
		}
	}

private renderFieldForProperty(p, owningClass, prefix = "") {
	boolean hasHibernate = pluginManager?.hasGrailsPlugin('hibernate') || pluginManager?.hasGrailsPlugin('hibernate4')
	boolean required = false
	if (hasHibernate) {
		cp = owningClass.constrainedProperties[p.name]
		required = (cp ? !(cp.propertyType in [boolean, Boolean]) && !cp.nullable : false)
	}
	if(hiddenFields.contains(p.name)){%>
		<g:hiddenField name="${p.name}" value="1" />
	<%}else{%>
<div class="form-group \${hasErrors(bean: ${propertyName}, field: '${prefix}${p.name}', 'error')} ${required ? 'required' : ''}">
	<label for="${prefix}${p.name}" class="col-sm-2 control-label">
		<g:message code="${domainClass.propertyName}.${prefix}${p.name}.label" default="${p.naturalName}" />
		<% if (required) { %><span class="required-indicator">*</span><% } %>
	</label>
	<div class="col-sm-5">
		${renderEditor(p)}
		<g:hasErrors bean="\${${propertyName}}" field="${prefix}${p.name}">
			<span class="help-block error"><g:renderErrors bean="\${${propertyName}}" field="${prefix}${p.name}" as="list" /></span>
		</g:hasErrors>
	</div>
</div>
<%  } } %>

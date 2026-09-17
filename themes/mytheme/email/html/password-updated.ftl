<#import "template.ftl" as layout>
<@layout.emailLayout>
    ${kcSanitize(msg("passwordUpdatedBodyHtml",email))?no_esc}
</@layout.emailLayout>

#include <assert.h>
#include <libxml/parser.h>
#include <libxml/xpath.h>
#include <libxml/xpathInternals.h>

int main(void) {
    const char xml[] = "<record xmlns=\"urn:example:record\" id=\"42\"/>";
    xmlDocPtr doc = xmlReadMemory(xml, sizeof(xml) - 1, "record.xml", NULL, XML_PARSE_NONET);
    assert(doc);
    xmlXPathContextPtr context = xmlXPathNewContext(doc);
    assert(context);
    assert(xmlXPathRegisterNs(context, BAD_CAST "r", BAD_CAST "urn:example:record") == 0);
    xmlXPathObjectPtr result = xmlXPathEvalExpression(BAD_CAST "string(/r:record/@id)", context);
    assert(result && result->type == XPATH_STRING);
    assert(xmlStrEqual(result->stringval, BAD_CAST "42"));
    xmlXPathFreeObject(result);
    xmlXPathFreeContext(context);
    xmlFreeDoc(doc);
    return 0;
}

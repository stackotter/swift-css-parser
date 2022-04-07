extern "C" {
#include "CCSSParser.h"
}

#include <CSSParser.h>

void dumpCSS(char *css) {
    CSSParser csst;

    std::string css_file = css;

    // valid css levels are "CSS1.0", "CSS2.0", "CSS2.1", "CSS3.0"
    csst.set_level("CSS3.0");

    // do the actual parsing
    csst.parse_css(css_file);

    // check for any parse errors
    std::vector<std::string> errors = csst.get_parse_errors();
    std::cout << "Errors: " << errors.size() << std::endl;
    for(int i = 0; i < errors.size(); i++) {
        std::cout << "  Error: " << errors[i] << std::endl;
    }

    // check for any parse warnings
    std::vector<std::string> warnings = csst.get_parse_warnings();
    std::cout << "Warnings: " << warnings.size() << std::endl;
    for(int i = 0; i < warnings.size(); i++) {
        std::cout << "  Warning: " << warnings[i] << std::endl;
    }

    // check for any parse information messages
    std::vector<std::string> infos = csst.get_parse_info();
    std::cout << "Information: " << infos.size() << std::endl;
    for(int i = 0; i < infos.size(); i++) {
        std::cout << "  Information: " << infos[i] << std::endl;
    }

    // get any @charset without having to walk the csstokens list
    std::string cset = csst.get_charset();
    if (!cset.empty()) std::cout << "charset: " << cset << std::endl;

    // get all @import without having to walk the csstokens list
    std::vector<std::string> imports = csst.get_import();
    for(int i = 0; i < imports.size(); i++) {
        std::cout << "import: " << imports[i] << std::endl;
    }

    // get any @namespace without having to walk the csstokens list
    std::string ns = csst.get_namespace();
    if (!ns.empty()) std::cout << "namespace: " << ns << std::endl;

    // The possible token type are an enum:
    // enum token_type:
    //
    //     CHARSET   =  0
    //     IMPORT    =  1
    //     NAMESP    =  2
    //     AT_START  =  3
    //     AT_END    =  4
    //     SEL_START =  5
    //     SEL_END   =  6
    //     PROPERTY  =  7
    //     VALUE     =  8
    //     COMMENT   =  9
    //     CSS_END   = 10

    // now walk the sequence of parsed tokens
    // if you know the location of the token you want in the sequence (starting with 0)
    // simply pass start_ptr in get_next_token set to a valid starting point in the token sequence

    CSSParser::token atoken = csst.get_next_token();
    while(atoken.type != CSSParser::CSS_END) {
        std::string ttype = csst.get_type_name(atoken.type);
        std::cout << "Pos: " << atoken.pos << " Line: " << atoken.line << " Type: " << ttype
        <<"  Data: " << atoken.data << std::endl;
        atoken = csst.get_next_token();
    }

    // serialize CSS to stdout if no output file is specified
    std::string cssout = csst.serialize_css();
}

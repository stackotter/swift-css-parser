extern "C" {
#include "CCSSParser.h"
}

#include <CSSParser.h>

extern "C" {

/// Creates a new instance of a parser. Must be freed when finished with (see `css_parser_destroy`).
CCSSParser * css_parser_create() {
    CSSParser *parser = reinterpret_cast<CSSParser *>(new CSSParser());
    return reinterpret_cast<CCSSParser *>(parser);
}

/// Destroys a parser.
/// @param parser The parser to destroy.
void css_parser_destroy(CCSSParser *parser) {
    delete reinterpret_cast<CSSParser *>(parser);
}

/// Set the parser's specification version.
/// @param parser The parser to modify.
/// @param level The specification version to use.
void css_parser_set_level(CCSSParser *parser, const char *level) {
    reinterpret_cast<CSSParser *>(parser)->set_level(level);
}

/// Parse CSS from a string.
/// @param parser The parser to use for parsing.
/// @param css A string containing CSS to parse.
void css_parser_parse_css(CCSSParser *parser, const char *css) {
    reinterpret_cast<CSSParser *>(parser)->parse_css(css);
}

/// Get an error message containing all errors encountered. `NULL` is returned if no errors were encountered.
/// @param parser The parser to get errors for.
char * css_parser_get_error(CCSSParser *parser) {
    std::vector<std::string> errors = reinterpret_cast<CSSParser *>(parser)->get_parse_errors();

    if (errors.empty())
        return NULL;

    // Calculate total error message length
    size_t error_length = 0;
    for(int i = 0; i < errors.size(); i++) {
        error_length += errors[i].length() + 1; // An additional char for the newline separator
    }

    char *error = reinterpret_cast<char *>(malloc(error_length));
    size_t current_index = 0;
    for(int i = 0; i < errors.size(); i++) {
        size_t count = errors[i].length();
        memcpy(error + current_index, errors[i].data(), count);
        current_index += count + 1;

        error[current_index - 1] = '\n';
    }

    // Remove the final new line
    error[current_index - 1] = 0;

    return error;
}

CToken css_parser_get_next_token(CCSSParser *parser) {
    CSSParser::token token = reinterpret_cast<CSSParser *>(parser)->get_next_token();
    
    char *data = reinterpret_cast<char *>(malloc(token.data.length()));
    strncpy(data, token.data.c_str(), token.data.length());
    data[token.data.length()] = 0;

    CToken c_token;
    c_token.type = static_cast<CTokenType>(token.type);
    c_token.data = data;
    return c_token;
}

void css_token_free(CToken token) {
    free(token.data);
}

}

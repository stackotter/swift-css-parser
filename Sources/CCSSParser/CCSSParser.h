// MARK: Parser types

struct CCSSParser;
typedef struct CCSSParser CCSSParser;

enum CTokenType {
    CHARSET, IMPORT, NAMESP, AT_START, AT_END, SEL_START, SEL_END, PROPERTY, VALUE, COMMENT, CSS_END
};
typedef enum CTokenType CTokenType;

struct CToken
{
    CTokenType type;
    char *data;
};
typedef struct CToken CToken;

// MARK: Parser lifecycle

CCSSParser * css_parser_create();
void css_parser_destroy(CCSSParser *parser);

// MARK: Parser configuration

void css_parser_set_level(CCSSParser *parser, const char *level);

// MARK: Parsing

void css_parser_parse_css(CCSSParser *parser, const char *css);
char * css_parser_get_error(CCSSParser *parser);

CToken css_parser_get_next_token(CCSSParser *parser);
void css_token_free(CToken token);

void dump_css(const char *css);

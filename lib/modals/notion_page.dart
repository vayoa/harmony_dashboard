class NotionPageScheme {
  final String parent;
  final String input;
  final String result;
  final String expected;
  final String testName;
  final String details;

  NotionPageScheme({
    required this.parent,
    required this.input,
    required this.result,
    required this.expected,
    required this.testName,
    required this.details,
  });

  Map<String, dynamic> toJson() => {
        "parent": {"database_id": parent},
        "properties": {
          "Name": {
            "title": [
              {
                "text": {
                  "content":
                      '"${input.replaceAll('"', "'")}" should be "${expected.replaceAll('"', "'")}".'
                }
              }
            ]
          },
          "Input": {
            "rich_text": [
              {
                "text": {"content": input}
              }
            ]
          },
          "Result": {
            "rich_text": [
              {
                "text": {"content": result}
              }
            ]
          },
          "Expected": {
            "rich_text": [
              {
                "text": {"content": expected}
              }
            ]
          },
          "Priority": {
            "select": {"name": 'P3'}
          },
          "Related Test": {
            "select": {"name": testName}
          },
          "Status": {
            "select": {"name": 'Not Started'}
          },
        },
        "children": [
          {
            "object": "block",
            "heading_1": {
              "rich_text": [
                {
                  "text": {"content": "Report Details"}
                }
              ]
            },
          },
          {
            "object": "block",
            "paragraph": {
              "rich_text": [
                {
                  "text": {"content": details}
                }
              ]
            },
          },
        ]
      };
}

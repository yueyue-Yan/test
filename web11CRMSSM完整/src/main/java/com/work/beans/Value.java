package com.work.beans;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Value {

    String id;
    String value;
    String text;
    int orderNo;
    String typeCode;

    Type type;

}

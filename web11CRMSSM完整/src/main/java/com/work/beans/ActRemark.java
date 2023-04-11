package com.work.beans;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ActRemark implements Serializable {
    String id;
    String notePerson;
    String noteContent;
    String noteTime;
    String editPerson;
    String editTime;
    int    editFlag;
    String marketingActivitiesId;

    //Activity activity;

}

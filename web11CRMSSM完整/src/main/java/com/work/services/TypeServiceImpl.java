package com.work.services;

import com.work.beans.Type;
import com.work.mapper.TypeMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TypeServiceImpl implements TypeService{
    @Autowired
    TypeMapper typeMapper;

    @Override
    public Type get(String id) {
        return typeMapper.get(id);
    }

    @Override
    public List<Type> getAll() {
        return typeMapper.getAll();
    }

    @Override
    public int save(Type type) {
        return typeMapper.save(type);
    }

    @Override
    public int edit(Type type) {
        return typeMapper.edit(type);
    }

    @Override
    public int delete(String[] ids) {
        return typeMapper.delete(ids);
    }
}

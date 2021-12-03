package com.example.dns;

import java.util.Objects;

public class StringState {
    private String key;
    private String stringValue;
    private String value;

    public StringState(String key, String stringValue, String value) {
        this.key = key;
        this.stringValue = stringValue;
        this.value = value;
    }

    public String getKey() {
        return key;
    }

    public String getStringValue() {
        return stringValue;
    }

    public String getValue() {
        return value;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }

        if ((obj == null) || (getClass() != obj.getClass())) {
            return false;
        }

        StringState other = (StringState) obj;

        return Objects.deepEquals(new String[] {getKey(), getValue()},
                new String[] {other.getKey(), other.getValue()});
    }

    @Override
    public int hashCode() {
        return Objects.hash(getKey(), getValue());
    }

    @Override
    public String toString() {
        return this.getClass().getSimpleName() + "@" + Integer.toHexString(hashCode()) + " [key=" + key + ", value="
                + stringValue + "]";
    }

}

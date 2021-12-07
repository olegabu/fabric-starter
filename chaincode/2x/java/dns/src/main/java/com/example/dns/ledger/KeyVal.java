package com.example.dns.ledger;

import java.util.Objects;

public class KeyVal {
    private String key;
    private String value;

    public KeyVal(String key, String value) {
        this.key = key;
        this.value = value;
    }

    public String getKey() {
        return key;
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

        KeyVal other = (KeyVal) obj;

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
                + value + "]";
    }

}

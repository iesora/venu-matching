import React, { Children } from "react";
import { Input } from "antd";

interface InputTextProps {
  label: string;
  attention?: string;
  children: React.ReactNode;
}

const InputText: React.FC<InputTextProps> = ({
  label,
  attention,
  children,
}) => {
  return (
    <div style={{ marginBottom: "20px" }}>
      <div
        style={{
          borderLeft: "5px solid lightgray",
          marginBottom: "12px",
          paddingLeft: "6px",
          fontWeight: "semibold",
          display: "flex",
          alignItems: "flex-end",
        }}
      >
        <div>{label}</div>
        {attention && (
          <div style={{ fontSize: "12px", color: "gray", marginLeft: "6px" }}>
            ※{attention}
          </div>
        )}
      </div>
      {children}
    </div>
  );
};

export default InputText;

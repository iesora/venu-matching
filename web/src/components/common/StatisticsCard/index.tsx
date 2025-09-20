import React from "react";
import { Card } from "antd";
import { subTextColor, textColor } from "@/utils/colors";

interface StatisticsCardProps {
  title: string;
  content: React.ReactNode;
  subContent?: string;
  icon?: React.ReactNode;
}

const StatisticsCard: React.FC<StatisticsCardProps> = ({
  title,
  content,
  subContent,
  icon,
}) => {
  return (
    <Card>
      <div style={{ display: "flex" }}>
        <div style={{ width: "80%" }}>
          <div
            style={{
              fontSize: "14px",
              color: textColor,
              marginBottom: "4px",
              letterSpacing: "0.5px",
            }}
          >
            {title}
          </div>
          <div style={{ marginBottom: "4px" }}>{content}</div>
          {subContent && (
            <div style={{ fontSize: "11px", color: subTextColor }}>
              {subContent}
            </div>
          )}
        </div>
        <div
          style={{
            color: subTextColor,
            textAlign: "right",
            width: "20%",
            fontSize: "20px",
          }}
        >
          {icon}
        </div>
      </div>
    </Card>
  );
};

export default StatisticsCard;

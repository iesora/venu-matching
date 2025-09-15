import React, { useState } from "react";
// import PageLayout from "@/components/common/PageLayout";
import { Upload, Button, message } from "antd";
import { InboxOutlined } from "@ant-design/icons";
import { textColor, subTextColor } from "@/utils/colors";
import axios from "axios";
import { axiosInstance } from "@/utils/url";
import PageLayout from "@/components/common/PageLayout";

const Index = () => {
  return (
    <PageLayout>
      <div style={{ marginBottom: "40px" }}>
        <div
          style={{
            fontSize: "26px",
            fontWeight: "bold",
            marginBottom: "8px",
            color: textColor,
          }}
        >
          Hello World
        </div>
      </div>

      <div
        style={{
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
          minHeight: "400px",
          minWidth: "300px",
          flexDirection: "column",
        }}
      ></div>
    </PageLayout>
  );
};

export default Index;

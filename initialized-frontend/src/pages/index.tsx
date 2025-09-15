import React from "react";
import PageLayout from "@/components/common/PageLayout";
import { Col, Row, Card, Divider, List, Typography } from "antd";
import { UserOutlined, CalendarOutlined } from "@ant-design/icons";
import {
  accentBgColor,
  accentTextColor,
  subTextColor,
  textColor,
} from "@/utils/colors";
import StatisticsCard from "@/components/common/StatisticsCard";

const Index = () => {
  const data = [
    "Racing car sprays burning fuel into crowd.",
    "Japanese princess to wed commoner.",
    "Australian walks 100km after outback crash.",
    "Man charged over missing wedding girl.",
    "Los Angeles battles huge wildfires.",
  ];

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
          ダッシュボード
        </div>
        <div style={{ color: subTextColor }}>店舗の状況を確認できます</div>
        <Divider />
      </div>
      <Row gutter={[16, 16]}>
        <Col span={6}>
          <StatisticsCard
            title="予約数"
            content={
              <div style={{ display: "flex", alignItems: "flex-end" }}>
                <div
                  style={{
                    fontSize: "24px",
                    fontWeight: "800",
                    color: textColor,
                  }}
                >
                  100
                </div>
                <div
                  style={{
                    fontSize: "14px",
                    color: subTextColor,
                    marginLeft: "4px",
                  }}
                >
                  件
                </div>
              </div>
            }
            subContent="前日比 +10%"
            icon={<CalendarOutlined />}
          />
        </Col>
        <Col span={6}>
          <StatisticsCard
            title="今月の売上"
            content={
              <div style={{ display: "flex", alignItems: "flex-end" }}>
                <div
                  style={{
                    fontSize: "24px",
                    fontWeight: "800",
                    color: textColor,
                  }}
                >
                  ¥128,500
                </div>
              </div>
            }
            subContent="前日比 +15%"
            icon={<CalendarOutlined />}
          />
        </Col>
        <Col span={6}>
          <StatisticsCard
            title="顧客総数"
            content={
              <div style={{ display: "flex", alignItems: "flex-end" }}>
                <div
                  style={{
                    fontSize: "24px",
                    fontWeight: "800",
                    color: textColor,
                  }}
                >
                  254
                </div>
                <div
                  style={{
                    fontSize: "14px",
                    color: subTextColor,
                    marginLeft: "4px",
                  }}
                >
                  人
                </div>
              </div>
            }
            subContent="前日比 +22%"
            icon={<CalendarOutlined />}
          />
        </Col>
        <Col span={6}>
          <StatisticsCard
            title="新規顧客"
            content={
              <div style={{ display: "flex", alignItems: "flex-end" }}>
                <div
                  style={{
                    fontSize: "24px",
                    fontWeight: "800",
                    color: textColor,
                  }}
                >
                  12
                </div>
                <div
                  style={{
                    fontSize: "14px",
                    color: subTextColor,
                    marginLeft: "4px",
                  }}
                >
                  人/週
                </div>
              </div>
            }
            subContent="前日比 +28%"
            icon={<CalendarOutlined />}
          />
        </Col>
        <Col span={12}>
          <Card>
            <div
              style={{ fontSize: "24px", fontWeight: "800", color: textColor }}
            >
              今日の予約
            </div>
            <div style={{ fontSize: "14px", color: subTextColor }}>
              本日の予約状況を確認できます
            </div>
            <List
              size="large"
              dataSource={data}
              renderItem={(item) => (
                <List.Item style={{ padding: "12px 0", cursor: "pointer" }}>
                  <div style={{ display: "flex", alignItems: "center" }}>
                    <div
                      style={{
                        backgroundColor: accentBgColor,
                        borderRadius: "100%",
                        height: "40px",
                        width: "40px",
                        padding: "12px",
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "center",
                      }}
                    >
                      <UserOutlined style={{ color: accentTextColor }} />
                    </div>
                    <div>
                      <div>eee</div>
                      <div>eee</div>
                    </div>
                  </div>
                  <div>
                    <div>aaa</div>
                    <div>eee</div>
                  </div>
                </List.Item>
              )}
            />
          </Card>
        </Col>
        <Col span={12}>
          <Card>
            <div
              style={{ fontSize: "24px", fontWeight: "800", color: textColor }}
            >
              売上レポート
            </div>
            <div style={{ fontSize: "14px", color: subTextColor }}>
              直近7日間の売上
            </div>
          </Card>
        </Col>
      </Row>
    </PageLayout>
  );
};

export default Index;

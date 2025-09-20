import React from "react";
import { Card, Row, Col, Spin, Alert, Typography, Tag, Button } from "antd";
import {
  EnvironmentOutlined,
  UserOutlined,
  ReloadOutlined,
  EyeOutlined,
} from "@ant-design/icons";
import { useAPIGetVenues } from "@/hook/api/venue/useAPIGetVenues";
import { Venue } from "@/type";
import PageLayout from "@/components/common/PageLayout";
import { useRouter } from "next/router";
import "@/styles/pages/Card.scss";

const { Title, Text } = Typography;

const VenueListPage: React.FC = () => {
  const { data: venues, isLoading, error, refetch } = useAPIGetVenues();
  const router = useRouter();

  if (isLoading) {
    return (
      <PageLayout>
        <div
          style={{
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
            height: "50vh",
          }}
        >
          <Spin size="large" />
        </div>
      </PageLayout>
    );
  }

  if (error) {
    return (
      <PageLayout>
        <Alert
          message="エラー"
          description={error.message}
          type="error"
          showIcon
          action={
            <Button size="small" danger onClick={() => refetch()}>
              再試行
            </Button>
          }
        />
      </PageLayout>
    );
  }

  return (
    <PageLayout>
      <div style={{ padding: "24px" }}>
        {venues?.length === 0 ? (
          <Card>
            <div style={{ textAlign: "center", padding: "48px 24px" }}>
              <EnvironmentOutlined
                style={{
                  fontSize: "48px",
                  color: "#ccc",
                  marginBottom: "16px",
                }}
              />
              <Title level={4} type="secondary">
                会場が見つかりません
              </Title>
              <Text type="secondary">会場が登録されていません。</Text>
            </div>
          </Card>
        ) : (
          <Row gutter={[24, 24]}>
            {venues?.map((venue: Venue) => (
              <Col xs={24} sm={24} md={12} lg={12} xl={12} key={venue.id}>
                <Card
                  hoverable
                  cover={
                    venue.imageUrl ? (
                      <img
                        alt={venue.name}
                        src={venue.imageUrl}
                        style={{ height: "300px", objectFit: "cover" }}
                      />
                    ) : (
                      <div
                        style={{
                          height: "300px",
                          backgroundColor: "#f5f5f5",
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "center",
                          color: "#999",
                        }}
                      >
                        <EnvironmentOutlined style={{ fontSize: "64px" }} />
                      </div>
                    )
                  }
                  onClick={() => router.push(`/venues/${venue.id}`)}
                  //   actions={[
                  //     <Button
                  //       type="link"
                  //       key="detail"
                  //       icon={<EyeOutlined />}
                  //       onClick={() => router.push(`/venues/${venue.id}`)}
                  //     >
                  //       詳細を見る
                  //     </Button>,
                  //   ]}
                  style={{ height: "100%" }}
                >
                  <Card.Meta
                    title={
                      <div>
                        <Text strong style={{ fontSize: "18px" }}>
                          {venue.name}
                        </Text>
                      </div>
                    }
                    description={
                      <div
                        style={{
                          minHeight: "200px",
                          display: "flex",
                          flexDirection: "column",
                          justifyContent: "space-between",
                        }}
                      >
                        <div>
                          <div style={{ marginBottom: "12px" }}>
                            <EnvironmentOutlined
                              style={{ marginRight: "8px" }}
                            />
                            <Text type="secondary" style={{ fontSize: "15px" }}>
                              {venue.address}
                            </Text>
                          </div>
                          {venue.description && (
                            <div style={{ marginBottom: "16px" }}>
                              <Text style={{ fontSize: "14px" }}>
                                {venue.description}
                              </Text>
                            </div>
                          )}
                        </div>
                        <div
                          style={{
                            gap: "8px",
                          }}
                        >
                          {venue.capacity && (
                            <Tag icon={<UserOutlined />} color="blue">
                              定員: {venue.capacity}人
                            </Tag>
                          )}
                        </div>
                      </div>
                    }
                  />
                </Card>
              </Col>
            ))}
          </Row>
        )}
      </div>
    </PageLayout>
  );
};

export default VenueListPage;

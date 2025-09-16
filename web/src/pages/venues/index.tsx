import React from "react";
import { Card, Row, Col, Spin, Alert, Typography, Tag, Button } from "antd";
import {
  EnvironmentOutlined,
  UserOutlined,
  DollarOutlined,
  ReloadOutlined,
} from "@ant-design/icons";
import { useAPIGetVenues } from "@/hook/api/venue/useAPIGetVenues";
import { Venue } from "@/type";
import PageLayout from "@/components/common/PageLayout";

const { Title, Text } = Typography;

const VenueListPage: React.FC = () => {
  const { data: venues, isLoading, error, refetch } = useAPIGetVenues();

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
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            marginBottom: "24px",
          }}
        >
          <Title level={2}>会場一覧</Title>
          <Button
            type="primary"
            icon={<ReloadOutlined />}
            onClick={() => refetch()}
            loading={isLoading}
          >
            更新
          </Button>
        </div>

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
          <Row gutter={[16, 16]}>
            {venues?.map((venue: Venue) => (
              <Col xs={24} sm={12} md={8} lg={6} key={venue.id}>
                <Card
                  hoverable
                  cover={
                    venue.imageUrl ? (
                      <img
                        alt={venue.name}
                        src={venue.imageUrl}
                        style={{ height: "200px", objectFit: "cover" }}
                      />
                    ) : (
                      <div
                        style={{
                          height: "200px",
                          backgroundColor: "#f5f5f5",
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "center",
                          color: "#999",
                        }}
                      >
                        <EnvironmentOutlined style={{ fontSize: "48px" }} />
                      </div>
                    )
                  }
                  actions={[
                    <Button type="link" key="detail">
                      詳細を見る
                    </Button>,
                  ]}
                >
                  <Card.Meta
                    title={
                      <div>
                        <Text strong style={{ fontSize: "16px" }}>
                          {venue.name}
                        </Text>
                      </div>
                    }
                    description={
                      <div>
                        <div style={{ marginBottom: "8px" }}>
                          <EnvironmentOutlined style={{ marginRight: "4px" }} />
                          <Text type="secondary">{venue.address}</Text>
                        </div>
                        {venue.description && (
                          <div style={{ marginBottom: "8px" }}>
                            <Text>{venue.description}</Text>
                          </div>
                        )}
                        <div
                          style={{
                            display: "flex",
                            flexWrap: "wrap",
                            gap: "8px",
                          }}
                        >
                          {venue.capacity && (
                            <Tag icon={<UserOutlined />} color="blue">
                              定員: {venue.capacity}人
                            </Tag>
                          )}
                          {venue.price && (
                            <Tag icon={<DollarOutlined />} color="green">
                              料金: ¥{venue.price.toLocaleString()}
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

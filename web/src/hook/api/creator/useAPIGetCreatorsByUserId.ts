import { useQuery } from "react-query";
import { axiosInstance } from "@/utils/url";
import { creatorByUserIdURL } from "@/utils/url/creator";
import { Creator } from "@/type";
import { AxiosError } from "axios";
import { jwtJsonHeader } from "@/utils/url/header";

const getCreatorsByUserId = async (userId?: number) => {
  const headers = jwtJsonHeader;
  const response = await axiosInstance.get(creatorByUserIdURL + `/${userId}`, {
    headers,
  });
  return response.data;
};

//idありで呼び出した場合はuserIdがないとリクエストが走らないよう設定
export const useAPIGetCreatorsByUserId = (userId?: number) => {
  return useQuery<Creator[], AxiosError>({
    queryKey: ["creatorsByUserId", userId],
    queryFn: () => getCreatorsByUserId(userId),
    enabled: userId !== undefined,
  });
};
